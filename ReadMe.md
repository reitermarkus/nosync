# Automatic iCloud `.nosync`

Automatically exclude some common “big” directories from iCloud sync.

Supported directories:

- JavaScript: `node_modules` directory
- Rust: `target` directory (next to a `Cargo.toml`)
- Ruby: `vendor/bundle` directory (next to a `Gemfile`)
- Python: parent path of a `pyvenv.cfg`

For transparent Git support, also add

```
*.nosync
```

to your global `.gitignore` file.
