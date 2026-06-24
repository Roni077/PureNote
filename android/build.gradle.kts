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
    
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val namespaceNode = android.javaClass.getMethod("getNamespace").invoke(android)
                if (namespaceNode == null) {
                    val group = project.group.toString()
                    android.javaClass.getMethod("setNamespace", String::class.java).invoke(android, group)
                }
            } catch (e: Exception) {
                // Ignore
            }
            try {
                android.javaClass.getMethod("setCompileSdkVersion", Int::class.java).invoke(android, 35)
            } catch (e: Exception) {
                try {
                    android.javaClass.getMethod("setCompileSdkVersion", String::class.java).invoke(android, "android-35")
                } catch (e2: Exception) {
                    // Ignore
                }
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
