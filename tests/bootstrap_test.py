import os
import unittest

class BootstrapDocTest(unittest.TestCase):
    def test_bootstrap_md_exists(self):
        path = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'BOOTSTRAP.md')
        path = os.path.normpath(path)
        self.assertTrue(os.path.exists(path), f"{path} should exist")

    def test_bootstrap_md_content(self):
        repo_root = os.path.dirname(os.path.dirname(__file__))
        path = os.path.join(repo_root, 'scripts', 'BOOTSTRAP.md')
        with open(path, 'r') as f:
            content = f.read()
        self.assertIn('Create a project with ID "lumi-test"', content)
        self.assertIn('Create an API key with all available scopes', content)
        self.assertIn('Write a file ".env.test"', content)

if __name__ == '__main__':
    unittest.main()
