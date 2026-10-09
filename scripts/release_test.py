import io
import json
from pathlib import Path
import tarfile
import tempfile
import unittest
from unittest.mock import patch

import release


class ReleaseTests(unittest.TestCase):
    def archive(self, root, target, project="ronna", revision="a" * 40):
        path = root / (project + "-" + target + ".tar.gz")
        metadata = {"project": project, "target": target,
                    "source_revision": revision, "exo_revision": "b" * 40}
        files = {"bin/" + binary: b"native executable" for binary in release.BINARIES[project]}
        files.update({"bin/exo": b"bundled runtime", "bin/exod": b"bundled daemon",
                      "share/ramp/ronna/plugin/ronna.lua": b"private bundled Lua",
                      "release.json": json.dumps(metadata).encode()})
        with tarfile.open(path, "w:gz") as archive:
            for name, data in files.items():
                member = tarfile.TarInfo(name)
                member.size = len(data)
                member.mode = 0o755 if name.startswith("bin/") else 0o644
                archive.addfile(member, io.BytesIO(data))
        return path

    def test_public_package_contains_only_selected_binaries_and_provenance(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = release.TARGETS[0]
            source = self.archive(root, target)
            destination = root / "public.tar.gz"
            release.repackage(source, destination, "ronna", "0.1.0", target, "a" * 40)
            original_digest = release.digest(destination)
            with tarfile.open(destination) as archive:
                self.assertEqual(set(archive.getnames()), {"bin", "bin/ronna", "release.json"})
                self.assertEqual(archive.getmember("bin/ronna").mode, 0o755)
                self.assertEqual(json.load(archive.extractfile("release.json"))["version"], "0.1.0")
            release.repackage(source, destination, "ronna", "0.1.0", target, "a" * 40)
            self.assertEqual(release.digest(destination), original_digest)

    def test_wrong_source_or_architecture_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = self.archive(root, release.TARGETS[0])
            for target, revision in ((release.TARGETS[1], "a" * 40), (release.TARGETS[0], "c" * 40)):
                with self.assertRaisesRegex(ValueError, "provenance mismatch"):
                    release.repackage(source, root / "public.tar.gz", "ronna", "0.1.0", target, revision)

    def test_bad_checksums_and_runtime_mismatch_do_not_write_a_formula(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "Formula").mkdir()
            (root / "releases").mkdir()
            (root / "releases/exo.json").write_text(json.dumps({"source_revision": "c" * 40}))

            for invalid_checksum in (True, False):
                def download(*args, **kwargs):
                    destination = Path(args[args.index("--dir") + 1])
                    archives = [self.archive(destination, target) for target in release.TARGETS]
                    (destination / "SHA256SUMS").write_text("".join(
                        ("0" * 64 if invalid_checksum else release.digest(path)) + "  " + path.name + "\n"
                        for path in archives))

                with patch.object(release, "ROOT", root), patch.object(release, "source_revision", return_value="a" * 40), patch.object(release, "run", side_effect=download):
                    error = "checksum mismatch" if invalid_checksum else "matching Exo runtime"
                    with self.assertRaisesRegex(ValueError, error):
                        release.prepare("ronna", "0.1.0")
                self.assertFalse((root / "Formula/ronna.rb").exists())
                self.assertFalse((root / "releases/ronna.json").exists())
            checksum = root / "bad-checksums"
            checksum.write_text("a" * 64 + "  ../../secret\n")
            with self.assertRaisesRegex(ValueError, "Invalid checksum"):
                release.checksums(checksum)

    def test_all_native_formula_variants_have_distinct_verified_assets(self):
        assets = {target: {"url": "https://example.com/" + target, "sha256": str(index) * 64}
                  for index, target in enumerate(release.TARGETS)}
        for project in release.BINARIES:
            formula = release.formula(project, "0.1.0", assets)
            for target in release.TARGETS:
                self.assertIn(assets[target]["url"], formula)
                self.assertIn(assets[target]["sha256"], formula)
            if project != "exo":
                self.assertIn('depends_on "kristalalfred/tap/exo"', formula)

    def test_published_source_version_rejects_a_different_revision(self):
        with patch.object(release, "release", return_value={"isDraft": False}), patch.object(release, "gh_json", return_value=[{"ref": "refs/tags/homebrew-v0.1.0"}]), patch.object(release, "source_revision", side_effect=["a" * 40, "b" * 40]):
            with self.assertRaisesRegex(ValueError, "different source revision"):
                release.build("exo", "0.1.0", "new-source")


if __name__ == "__main__":
    unittest.main()
