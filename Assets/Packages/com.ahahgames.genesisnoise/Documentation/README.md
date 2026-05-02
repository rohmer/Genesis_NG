# Genesis Documentation

This package ships with generated reference docs for both node wrappers and raw shader implementations.

## References

- [Node Reference](./Nodes/README.md)
- [Shader Reference](./Shaders/README.md)

## Regenerate

- Unity: run `Tools/Genesis Documentation` to capture screenshots, rebuild the Doxygen source browser, and refresh the markdown references.
- CLI: run the scripts below in order.

```powershell
pwsh ./Documentation/Generate-GenesisDoxygen.ps1
pwsh ./Documentation/Generate-GenesisNodeDocs.ps1
pwsh ./Documentation/Generate-GenesisShaderDocs.ps1
```
