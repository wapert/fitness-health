allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // biometric_storage 5.0.1 still declares compileSdk 31, while its
    // AndroidX dependencies require 34+. Keep the plugin aligned with the app.
    if (name == "biometric_storage") {
        afterEvaluate {
            extensions.configure<com.android.build.api.dsl.LibraryExtension> {
                compileSdk = 36
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
