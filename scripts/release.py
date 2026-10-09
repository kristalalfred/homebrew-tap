import argparse
import base64
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import tempfile
import time
import tomllib
from urllib.parse import quote


ROOT = Path(__file__).resolve().parents[1]
TAP = "kristalalfred/homebrew-tap"
TARGETS = (
    "aarch64-apple-darwin", "x86_64-apple-darwin",
    "aarch64-unknown-linux-gnu", "x86_64-unknown-linux-gnu",
)
BINARIES = {"exo": ("exo", "exod"), "ramp": ("ramp",), "ronna": ("ronna",)}
DESCRIPTIONS = {
    "exo": "Agent runtime and command-line client",
    "ramp": "Programmable terminal frontend for agent harnesses",
    "ronna": "Client for Ronna coding sessions and native runners",
}


def run(*args, capture=True):
    result = subprocess.run(args, check=True, text=True, capture_output=capture)
    return result.stdout.strip() if capture else None


def gh_json(*args):
    return json.loads(run("gh", *args))


def release(repo, tag):
    result = subprocess.run(
        ["gh", "release", "view", tag, "--repo", repo, "--json", "isDraft,tagName"],
        text=True, capture_output=True,
    )
    if result.returncode:
        if "release not found" not in result.stderr.lower():
            raise RuntimeError(result.stderr)
        return None
    return json.loads(result.stdout)


def source_revision(project, ref):
    return gh_json("api", f"repos/kristalalfred/{project}/commits/{quote(ref, safe='')}")["sha"]


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checksums(path):
    entries = {}
    for line in path.read_text().splitlines():
        checksum, name = line.split(maxsplit=1)
        name = name.lstrip("*")
        if not re.fullmatch(r"[a-f0-9]{64}", checksum) or Path(name).name != name or name in entries:
            raise ValueError("Invalid checksum entry: " + name)
        entries[name] = checksum
    return entries


def build(project, version, ref):
    repo = "kristalalfred/" + project
    tag = "homebrew-v" + version
    current = release(repo, tag)
    tags = gh_json("api", f"repos/{repo}/git/matching-refs/tags/{tag}")
    if not any(item["ref"] == "refs/tags/" + tag for item in tags):
        revision = source_revision(project, ref or "main")
        run("gh", "api", "--method", "POST", f"repos/{repo}/git/refs", "-f", "ref=refs/tags/" + tag, "-f", "sha=" + revision)
    revision = source_revision(project, tag)
    if ref and source_revision(project, ref) != revision:
        raise ValueError("The release tag already refers to a different source revision")
    manifest = "code/Cargo.toml" if project == "ronna" else "Cargo.toml"
    content = gh_json("api", f"repos/{repo}/contents/{manifest}?ref={tag}")
    package_version = tomllib.loads(base64.b64decode(content["content"]).decode())["workspace"]["package"]["version"]
    if package_version != version:
        raise ValueError(f"Source version is {package_version}, requested {version}")
    if current and not current["isDraft"]:
        print(f"Private release already exists: {repo}/{tag}")
        return
    query = ("run", "list", "--repo", repo, "--workflow", "release.yml", "--branch", tag,
             "--limit", "5", "--json", "databaseId,status,conclusion,headSha")
    runs = gh_json(*query)
    if not runs or runs[0]["conclusion"] not in ("", "success"):
        run("gh", "workflow", "run", "release.yml", "--repo", repo, "--ref", tag, capture=False)
        for _ in range(30):
            runs = gh_json(*query)
            if runs and runs[0]["status"] != "completed":
                break
            time.sleep(2)
        else:
            raise RuntimeError("The dispatched release build did not appear")
    workflow = runs[0]
    if workflow["headSha"] != revision:
        raise ValueError("Workflow source does not match the frozen release tag")
    run("gh", "run", "watch", str(workflow["databaseId"]), "--repo", repo, "--interval", "15", "--exit-status", capture=False)
    directory = ROOT / ".dist" / project / version / "build"
    if directory.exists():
        shutil.rmtree(directory)
    directory.mkdir(parents=True, exist_ok=True)
    run("gh", "run", "download", str(workflow["databaseId"]), "--repo", repo,
        "--pattern", project + "-*", "--dir", str(directory), capture=False)
    archives = sorted(directory.rglob("*.tar.gz"))
    expected = {f"{project}-{target}.tar.gz" for target in TARGETS}
    if project == "ronna":
        expected.update(f"ronna-server-{target}.tar.gz" for target in TARGETS)
    if {path.name for path in archives} != expected or len(archives) != len(expected):
        raise ValueError("The native build did not produce all expected archives")
    for archive in archives:
        if checksums(archive.with_name(archive.name + ".sha256"))[archive.name] != digest(archive):
            raise ValueError("Build checksum mismatch: " + archive.name)
    checksum_file = directory / "SHA256SUMS"
    checksum_file.write_text("".join(digest(path) + "  " + path.name + "\n" for path in archives))
    if not current:
        run("gh", "release", "create", tag, "--repo", repo, "--verify-tag", "--draft",
            "--title", f"{project} {version}", "--notes", "Native binaries from source revision " + revision)
    run("gh", "release", "upload", tag, "--repo", repo, "--clobber",
        *(str(path) for path in archives), str(checksum_file), capture=False)
    run("gh", "release", "edit", tag, "--repo", repo, "--draft=false", capture=False)
    print(f"Stored native archives in private release {repo}/{tag}")


def repackage(source, destination, project, version, target, revision):
    with tarfile.open(source, "r:gz") as archive:
        metadata = json.load(archive.extractfile("release.json"))
        if metadata["project"] != project or metadata["target"] != target or metadata["source_revision"] != revision:
            raise ValueError("Archive provenance mismatch: " + source.name)
        contents = {}
        for binary in BINARIES[project]:
            name = "bin/" + binary
            member = archive.getmember(name)
            if not member.isfile() or not member.mode & 0o111:
                raise ValueError("Expected an executable file: " + name)
            contents[name] = archive.extractfile(member).read()
    metadata["version"] = version
    contents["release.json"] = (json.dumps(metadata, indent=2) + "\n").encode()
    with destination.open("wb") as raw:
        with gzip.GzipFile(filename="", fileobj=raw, mode="wb", mtime=0) as compressed:
            with tarfile.open(fileobj=compressed, mode="w") as archive:
                directory = tarfile.TarInfo("bin")
                directory.type = tarfile.DIRTYPE
                directory.mode = 0o755
                archive.addfile(directory)
                for name, data in contents.items():
                    member = tarfile.TarInfo(name)
                    member.size = len(data)
                    member.mode = 0o755 if name.startswith("bin/") else 0o644
                    archive.addfile(member, io.BytesIO(data))
    return metadata


def formula(project, version, assets):
    lines = [f"class {project.capitalize()} < Formula", f'  desc "{DESCRIPTIONS[project]}"',
             f'  homepage "https://github.com/{TAP}#{project}"',
             '  license :cannot_represent' if project == "ronna" else '  license "MIT"']
    if project != "exo":
        lines.extend(["", '  depends_on "kristalalfred/tap/exo"'])
    for system, suffix in (("macos", "apple-darwin"), ("linux", "unknown-linux-gnu")):
        lines.extend(["", f"  on_{system} do"])
        if system == "macos":
            lines.append("    depends_on macos: :monterey")
            lines.append("")
        for architecture, cpu in (("arm", "aarch64"), ("intel", "x86_64")):
            asset = assets[cpu + "-" + suffix]
            lines.extend([f"    on_{architecture} do", f'      url "{asset["url"]}"'])
            if architecture == "intel":
                lines.append(f'      version "{version}"')
            lines.extend([f'      sha256 "{asset["sha256"]}"', "    end"])
            if architecture == "arm":
                lines.append("")
        lines.append("  end")
    binaries = ", ".join('"bin/' + binary + '"' for binary in BINARIES[project])
    lines.extend(["", "  def install", "    bin.install " + binaries,
                  '    pkgshare.install "release.json"', "  end", "", "  test do"])
    for binary in BINARIES[project]:
        lines.append(f'    assert_match version.to_s, shell_output("#{{bin}}/{binary} --version")')
    lines.extend(["  end", "end", ""])
    return "\n".join(lines)


def prepare(project, version):
    repo = "kristalalfred/" + project
    source_tag = "homebrew-v" + version
    revision = source_revision(project, source_tag)
    directory = ROOT / ".dist" / project / version
    private = directory / "private"
    public = directory / "public"
    if private.exists():
        shutil.rmtree(private)
    private.mkdir(parents=True)
    public.mkdir(parents=True, exist_ok=True)
    run("gh", "release", "download", source_tag, "--repo", repo,
        "--pattern", f"{project}-*.tar.gz", "--pattern", "SHA256SUMS", "--dir", str(private), capture=False)
    expected = checksums(private / "SHA256SUMS")
    assets = {}
    metadata = None
    tag = project + "-v" + version
    for target in TARGETS:
        name = f"{project}-{target}.tar.gz"
        source = private / name
        if expected.get(name) != digest(source):
            raise ValueError("Private release checksum mismatch: " + name)
        current = repackage(source, public / name, project, version, target, revision)
        if metadata and current["exo_revision"] != metadata["exo_revision"]:
            raise ValueError("Different Exo revisions across native builds")
        metadata = current
        assets[target] = {"url": f"https://github.com/{TAP}/releases/download/{tag}/{name}", "sha256": digest(public / name)}
    if project == "exo":
        if metadata["exo_revision"] != revision:
            raise ValueError("Exo archive does not describe its own source revision")
    else:
        runtime = json.loads((ROOT / "releases/exo.json").read_text())
        if runtime["source_revision"] != metadata["exo_revision"]:
            raise ValueError("Publish the matching Exo runtime before preparing this client")
    public.joinpath("SHA256SUMS").write_text("".join(assets[target]["sha256"] + f"  {project}-{target}.tar.gz\n" for target in TARGETS))
    record = {"project": project, "version": version, "source_revision": revision,
              "exo_revision": metadata["exo_revision"], "source_tag": source_tag,
              "release_tag": tag, "assets": assets}
    (ROOT / "releases").mkdir(exist_ok=True)
    (ROOT / f"releases/{project}.json").write_text(json.dumps(record, indent=2) + "\n")
    (ROOT / f"Formula/{project}.rb").write_text(formula(project, version, assets))
    print(f"Prepared {project} {version}; review and commit the formula and release record before publishing")


def publish(project, version):
    record = json.loads((ROOT / f"releases/{project}.json").read_text())
    if record["version"] != version:
        raise ValueError("The prepared version does not match the requested version")
    run("git", "ls-files", "--error-unmatch", f"Formula/{project}.rb", f"releases/{project}.json")
    run("git", "diff", "--exit-code", "HEAD", "--", f"Formula/{project}.rb", f"releases/{project}.json")
    commit = run("git", "rev-parse", "HEAD")
    public = ROOT / ".dist" / project / version / "public"
    expected = {f"{project}-{target}.tar.gz": record["assets"][target]["sha256"] for target in TARGETS}
    if checksums(public / "SHA256SUMS") != expected:
        raise ValueError("Prepared checksum file does not match the release record")
    for target in TARGETS:
        if digest(public / f"{project}-{target}.tar.gz") != record["assets"][target]["sha256"]:
            raise ValueError("Prepared binary checksum mismatch")
    tag = record["release_tag"]
    existing = release(TAP, tag)
    if existing and not existing["isDraft"]:
        with tempfile.TemporaryDirectory(prefix="tap-release-") as directory:
            run("gh", "release", "download", tag, "--repo", TAP, "--pattern", "SHA256SUMS", "--dir", directory)
            if checksums(Path(directory) / "SHA256SUMS") != checksums(public / "SHA256SUMS"):
                raise ValueError("Published versions are immutable; choose a new version")
        print("Public release already matches: " + tag)
        return
    if not existing:
        run("gh", "release", "create", tag, "--repo", TAP, "--target", commit, "--draft",
            "--title", f"{project} {version}", "--notes", "Native macOS and Linux binaries for arm64 and x86_64. Install through kristalalfred/tap; Lua plugins are installed separately through Git.")
    run("gh", "release", "upload", tag, "--repo", TAP, "--clobber",
        *(str(public / f"{project}-{target}.tar.gz") for target in TARGETS), str(public / "SHA256SUMS"), capture=False)
    run("gh", "release", "edit", tag, "--repo", TAP, "--draft=false", capture=False)
    print("Published https://github.com/" + TAP + "/releases/tag/" + tag)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("build", "prepare", "publish"))
    parser.add_argument("project", choices=tuple(BINARIES))
    parser.add_argument("version")
    parser.add_argument("--ref")
    args = parser.parse_args()
    if not re.fullmatch(r"\d+\.\d+\.\d+", args.version):
        parser.error("version must be a stable major.minor.patch version")
    if args.action == "build":
        build(args.project, args.version, args.ref)
    elif args.action == "prepare":
        prepare(args.project, args.version)
    else:
        publish(args.project, args.version)


if __name__ == "__main__":
    main()
