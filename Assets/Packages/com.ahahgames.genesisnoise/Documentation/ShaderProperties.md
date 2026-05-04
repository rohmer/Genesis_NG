# Shader Properties

## Property decorations
*InlineTexture* - A macro for 2D, 3D and Cubemap, used like:
```
[InlineTexture(HideInNodeInspector)] _UV_2D("UVs", 2D) = "uv" {}
[InlineTexture(HideInNodeInspector)] _UV_3D("UVs", 3D) = "uv" {}
[InlineTexture(HideInNodeInspector)] _UV_Cube("UVs", Cube) = "uv" {}
```
The variable name for that is _UV, or everything before the second _.  Example:
_Texture_2D the variable name would be _Texture

*ShowInInspector* or *HideInInspector* - Overrides the default viewing of that property with what is defined here

*KeywordEnum* or *Enum* - An enumeration of options

*ToolTip* - The documentation attribute for this property

*VisibleIf* - Will show a property only if the visibleif statement is true

Syntax:
```
VisibleIf(VARIABLE, VALID_VALUE, ...)
or
VisibleIf(_ShowMe,1,2,3)
```
Where there may be 1-n valid values.  This property will only be visible if this evaluates to true in runtime.  In this example, the property would be shown if _ShowMe is equal to 1, 2 or 3.



