buildscript {
    val libraryProperties = java.util.Properties()
    file("../gradle.properties").inputStream().use { libraryProperties.load(it) }
    project.extra["modVersion"] = libraryProperties.getProperty("mod_version")
}

plugins {
    id("com.gtnewhorizons.gtnhconvention")
}
