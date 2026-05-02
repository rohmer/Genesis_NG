using UnityEditor;

public static class PackageExporter
{
    [MenuItem("Tools/Build UnityPackage")]
    public static void Build()
    {
        AssetDatabase.ExportPackage(
            new[] { "Assets/Packages/com.ahahgames.genesisnoise" },
            "MyPackage.unitypackage",
            ExportPackageOptions.Recurse | ExportPackageOptions.IncludeDependencies
        );
    }
}