using System;

namespace AhahGames.GenesisNoise
{
    [AttributeUsage(AttributeTargets.Class)]
    public class DocumentationAttribute : Attribute
    {
        public string markdown;

        public DocumentationAttribute(string markdown)
        {
            this.markdown = markdown;
        }
    }
}