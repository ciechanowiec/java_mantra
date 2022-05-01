#!/bin/bash

# @author Herman Ciechanowiec, herman@ciechanowiec.eu
# This program is a Shell script for Linux Ubuntu. Its purpose is to provide
# an easy-to-use and convenient tool for creating clean Java projects with basic
# dependencies and configuration out of the box (Maven, Git, TestNG etc.).
# For more information checkout https://github.com/ciechanowiec/mantra

# ============================================== #
#                                                #
#                   FUNCTIONS                    #
#                                                #
# ============================================== #

showWelcomeMessage () {
	printf "\n\e[1m=====================\n"
	printf "MANTRA SCRIPT STARTED\n"
	printf "=====================\e[0m\n"
}

verifyIfTreeExists () {
	if ! command tree -v &> /dev/null
	then
		printf "\e[1;91m[ERROR]:\e[0m 'tree' package which is needed to run the script hasn't been detected and the script has stopped. Try to install 'tree' package using command 'sudo apt install tree'.\n\n"
    		exit
	fi
}

verifyIfGitExists () {
	if ! command git --version &> /dev/null
	then
		printf "\e[1;91m[ERROR]:\e[0m 'git' package which is needed to run the script hasn't been detected and the script has stopped. Try to install 'git' package using command 'sudo apt install git'.\n\n"
		exit
	fi
}

verifyIfTwoArguments () {	
	if [ $# != 2 ]
	then
		printf "\e[1;91m[ERROR]:\e[0m The script must be provided with exactly two arguments. The first one should be an absolute path where the project directory is to be created and the second one should be the project name. This condition hasn't been met and the script has stopped.\n\n"
		exit
	fi
}

verifyIfOneArgument () {
	if [ $# != 1 ]
	then
    		printf "\e[1;91m[ERROR]:\e[0m The script must be provided with exactly one argument: the project name. This condition hasn't been met and the script has stopped.\n\n"
		exit
	fi
}

verifyIfCorrectPath () {
pathUntilProjectDirectory=$1
	if [[ ! "$pathUntilProjectDirectory" =~ ^\/.* ]]
	then
		printf "\e[1;91m[ERROR]:\e[0m As the first argument for the script an absolute path where the project directory is to be created should be provided. This condition hasn't been met and the script has stopped.\n\n"
		exit
	fi
}

verifyIfCorrectName () {
projectName=$1
	if [[ ! "$projectName" =~ ^[a-z]{1}([a-z0-9]*)$ ]]
	then
		printf "\e[1;91m[ERROR]:\e[0m The provided project name may consist only of lower case letters and numbers; the first character should be a letter. This condition hasn't been met and the script has stopped.\n\n"
		exit
	fi
}

verifyIfProjectDirectoryExists () {
projectDirectory=$1
	if [ -d $projectDirectory ]
	then
		printf "\e[1;91m[ERROR]:\e[0m The project already exists in \e[3m$projectDirectory\e[0m. The script has stopped.\n\n"
		exit
	fi
}

createProjectDirectory () {
projectDirectory=$1
	mkdir -p $projectDirectory
	printf "\e[1;96m[STATUS]:\e[0m The project directory \e[3m$projectDirectory\e[0m has been created.\n"
}

createFilesStructure () {
projectDirectory=$1
firstLevelPackageName=$2
secondLevelPackageName=$3
projectName=$4
	mkdir -p $1/src/{main/{java/$firstLevelPackageName/$secondLevelPackageName/$projectName,resources},test/java/$firstLevelPackageName/$secondLevelPackageName/$projectName}
	touch $1/src/main/java/$firstLevelPackageName/$secondLevelPackageName/$projectName/Main.java
	touch $1/src/main/resources/tinylog.properties
	touch $1/src/test/java/$firstLevelPackageName/$secondLevelPackageName/$projectName/MainTest.java
	touch $1/pom.xml
	touch $1/README.md
	printf "\e[1;96m[STATUS]:\e[0m The following file structure for the project has been created:\n"
	tree $1
}

insertContentToMain () {
projectDirectory=$1
firstLevelPackageName=$2
secondLevelPackageName=$3
projectName=$4
gitCommitterName=$5
gitCommitterSurname=$6
mainFile=$projectDirectory/src/main/java/$firstLevelPackageName/$secondLevelPackageName/$projectName/Main.java
cat > $mainFile << EOF
package $firstLevelPackageName.$secondLevelPackageName.$projectName;

import org.tinylog.Logger;

/**
 * @author $gitCommitterName $gitCommitterSurname
 */
class Main {

    public static void main(String[] args) {
        Logger.info("Application started.");
        System.out.println("Hello, Universe!");
        Logger.info("Application ended.");
    }
}		
EOF
printf "\e[1;96m[STATUS]:\e[0m Default Java-content has been added to \e[3mMain.java\e[0m.\n" 
}

insertContentToLoggerProperties () {
loggerPropertiesFile=$1/src/main/resources/tinylog.properties
cat > $loggerPropertiesFile << EOF
writer        = file
writer.format = {date: yyyy-MM-dd HH:mm:ss.SSS O} {level}: {message}
writer.file   = logs.txt
EOF
printf "\e[1;96m[STATUS]:\e[0m Default logger properties has been added to \e[3mtinylog.properties\e[0m.\n" 
}

insertContentToMainTest () {
projectDirectory=$1
firstLevelPackageName=$2
secondLevelPackageName=$3
projectName=$4
mainTestFile=$projectDirectory/src/test/java/$firstLevelPackageName/$secondLevelPackageName/$projectName/MainTest.java
cat > $mainTestFile << EOF
package $firstLevelPackageName.$secondLevelPackageName.$projectName;

import org.testng.annotations.Test;

import static org.testng.Assert.assertTrue;

public class MainTest {

    @Test
    public void sampleTrueTest() {
        assertTrue(true);
    }
}
EOF
printf "\e[1;96m[STATUS]:\e[0m Default TestNG-content has been added to \e[3mMainTest.java\e[0m.\n"	
}

insertContentToPom () {
projectDirectory=$1
firstLevelPackageName=$2
secondLevelPackageName=$3
projectName=$4
projectURL=$5
pomFile=$projectDirectory/pom.xml
cat > $pomFile << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>$firstLevelPackageName.$secondLevelPackageName.$projectName</groupId>
  <artifactId>$projectName</artifactId>
  <version>1.0</version>
  <packaging>jar</packaging>

  <name>$projectName</name>
  <description>Java Program</description>
  <url>$projectURL</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.release>17</maven.compiler.release>
    <testng.version>7.5</testng.version>
    <tinylog-api.version>2.5.0-M1.1</tinylog-api.version>
    <tinylog-impl.version>2.5.0-M1.1</tinylog-impl.version>
    <maven-compiler-plugin.version>3.10.1</maven-compiler-plugin.version>
    <maven-resources-plugin.version>3.2.0</maven-resources-plugin.version>
    <maven-jar-plugin.version>3.2.2</maven-jar-plugin.version>
    <maven-dependency-plugin.version>3.3.0</maven-dependency-plugin.version>
    <maven-surefire-plugin.version>3.0.0-M5</maven-surefire-plugin.version>
    <maven-failsafe-plugin.version>3.0.0-M5</maven-failsafe-plugin.version>
    <jacoco-maven-plugin.version>0.8.7</jacoco-maven-plugin.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.testng</groupId>
      <artifactId>testng</artifactId>
      <version>\${testng.version}</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.tinylog</groupId>
      <artifactId>tinylog-api</artifactId>
      <version>\${tinylog-api.version}</version>
    </dependency>
    <dependency>
      <groupId>org.tinylog</groupId>
      <artifactId>tinylog-impl</artifactId>
      <version>\${tinylog-impl.version}</version>
    </dependency>
  </dependencies>

  <build>    
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>\${maven-compiler-plugin.version}</version>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-resources-plugin</artifactId>
        <version>\${maven-resources-plugin.version}</version>
        <executions>
          <execution>
            <id>copy-resources</id>
            <phase>validate</phase>
            <goals>
              <goal>copy-resources</goal>
            </goals>
            <configuration>
              <outputDirectory>/target/src/main/resources</outputDirectory>
              <includeEmptyDirs>true</includeEmptyDirs>
              <resources>
                <resource>
                  <directory>/src/main/resources</directory>
                  <filtering>false</filtering>
                </resource>
              </resources>
            </configuration>
          </execution>
        </executions>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>\${maven-jar-plugin.version}</version>
        <configuration>
          <archive>
            <manifest>
              <addClasspath>true</addClasspath>
	          <classpathPrefix>lib/</classpathPrefix> <!-- enables usage of dependencies from .jar
                                                           by copying them into the target folder -->
              <mainClass>$firstLevelPackageName.$secondLevelPackageName.$projectName.Main</mainClass>
            </manifest>
          </archive>
        </configuration>
      </plugin>
      <plugin>
        <!-- enables usage of dependencies from .jar
             by copying them into the target folder -->
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-dependency-plugin</artifactId>
        <version>\${maven-dependency-plugin.version}</version>
        <executions>
          <execution>
            <id>copy-dependencies</id>
            <phase>package</phase>
            <goals>
              <goal>copy-dependencies</goal>
            </goals>
            <configuration>
              <outputDirectory>\${project.build.directory}/lib</outputDirectory>
            </configuration>
          </execution>
        </executions>
      </plugin>
      <plugin>
        <!-- prevents from building if unit tests don't pass -->
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>\${maven-surefire-plugin.version}</version>
      </plugin>
      <plugin>
        <!-- prevents from building if integration tests don't pass -->
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-failsafe-plugin</artifactId>
        <version>\${maven-failsafe-plugin.version}</version>
      </plugin>
      <plugin>
        <!-- creates reports on tests coverage (target->site->jacoco->index.html) -->
        <groupId>org.jacoco</groupId>
        <artifactId>jacoco-maven-plugin</artifactId>
        <version>\${jacoco-maven-plugin.version}</version>
        <executions>
          <execution>
            <id>prepare-agent</id>
            <goals>
              <goal>prepare-agent</goal>
            </goals>
          </execution>
          <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
              <goal>report</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
EOF
printf "\e[1;96m[STATUS]:\e[0m Default Maven-content has been added to \e[3mpom.xml\e[0m.\n"
}

insertContentToReadme () {
readmeFile=$1/README.md
projectName=$2
date=`date +%F`
cat > $readmeFile << EOF
# $projectName

This project was created on $date from a template.
EOF
printf "\e[1;96m[STATUS]:\e[0m Default Readme-content has been added to \e[3mREADME.md\e[0m.\n"
}

addGitignore () {
projectDirectory=$1
touch $projectDirectory/.gitignore
gitignoreFile=$projectDirectory/.gitignore
cat > $gitignoreFile << EOF
# All files with .class extension:
*.class

# All files with .log extension + file named 'logs.txt':
*.log
logs.txt

# 'target' directory located directly in the project directory:
/target

# All files and directories which names start with . (dot), 
# except .git, .gitattributes and .gitignore:
.*
!/.git
!.gitattributes
!.gitignore
EOF
printf "\e[1;96m[STATUS]:\e[0m \e[3m.gitignore\e[0m has been created. It sets git to ignore:
	   \055 all files with \e[3m.class\e[0m extension
	   \055 all files with \e[3m.log\e[0m extension + file named \e[3mlogs.txt\e[0m
	   \055 \e[3mtarget\e[0m directory located directly in the project directory
	   \055 all files and directories which names start with \e[3m. (dot)\e[0m,
	     except \e[3m.git\e[0m, \e[3m.gitattributes\e[0m and \e[3m.gitignore\e[0m\n"
}

addGitAttributes () {
projectDirectory=$1
touch $projectDirectory/.gitattributes
gitattributesFile=$projectDirectory/.gitattributes
cat > $gitattributesFile << EOF
###############################
#        Line Endings         #
###############################

# Set default behaviour to automatically normalize line endings:
* text=auto

# Force batch scripts to always use CRLF line endings so that if a repo is accessed
# in Windows via a file share from Linux, the scripts will work:
*.{cmd,[cC][mM][dD]} text eol=crlf
*.{bat,[bB][aA][tT]} text eol=crlf

# Force bash scripts to always use LF line endings so that if a repo is accessed
# in Unix via a file share from Windows, the scripts will work:
*.sh text eol=lf
EOF
printf "\e[1;96m[STATUS]:\e[0m \e[3m.gitattributes\e[0m has been created. It sets git to normalize line endings.\n"
}

initGit () {
	projectDirectory=$1
	git init $projectDirectory &> /dev/null
	printf "\e[1;96m[STATUS]:\e[0m Git repository has been initialized.\n"
}

setupGitCommitter() {
	projectDirectory=$1
	gitCommitterName=$2
	gitCommitterSurname=$3
	gitCommitterEmail=$4
	currentDirectory=`pwd`
	cd $projectDirectory
	git config user.name "$gitCommitterName $gitCommitterSurname"
	git config user.email $gitCommitterEmail
	printf "\e[1;96m[STATUS]:\e[0m Git committer fot this project has been set up: $gitCommitterName $gitCommitterSurname <$gitCommitterEmail>.\n"
	cd $currentDirectory
}

showFinishMessage () {
	projectName=$1
	printf "\e[1;92m[SUCCESS]:\e[0m The project \e[3m$projectName\e[0m has been created.\n"
}

tryOpenWithVSCode () {
	projectName=$1
	projectDirectory=$2
	if command code -v &> /dev/null # Checks whether VS Code CLI command ('code') exists
	then
		printf "\e[1;93m[VS Code]:\e[0m Opening the project...\n"
		code -n $projectDirectory
	fi
}

tryOpenWithIntelliJ () {
	projectName=$1
	projectDirectory=$2
	if [ -f /snap/intellij-idea-community/current/bin/idea.sh ] # Checks whether a native IntelliJ IDEA launcher exists
	then
		printf "\e[1;93m[IntelliJ IDEA]:\e[0m Opening the project...\n"
		nohup /snap/intellij-idea-community/current/bin/idea.sh nosplash $projectDirectory 2>/dev/null &
	fi
}

# ============================================== #
#                                                #
#                  DRIVER CODE                   #
#                                                #
# ============================================== #

showWelcomeMessage
verifyIfTreeExists
verifyIfGitExists

# >> START OF A CONFIGURABLE BLOCK
gitCommitterName="Herman"
gitCommitterSurname="Ciechanowiec"
gitCommitterEmail="herman@ciechanowiec.eu"
firstLevelPackageName="eu"
secondLevelPackageName="ciechanowiec"
projectURL="https://ciechanowiec.eu/"
# << END OF A CONFIGURABLE BLOCK

# >> START OF A CONFIGURABLE BLOCK
# A. This block allows to configure how many arguments are
#    required to be passed to the script.
# B. The first set of functions requires exactly two arguments:
#    - an absolute path where the project directory is to be created
#    - a project name
# C. The second set of functions requires exactly one argument: a project name.
#    In the second set of functions an absolute path where the project directory
#    is to be created isn't passed to the script, but is hardcoded inside it.
# D. By default the first set of functions is active while the second set is inactive
#    and commented out. To switch between them comment out the first one, restore
#    from the comment the second one and provide your own value for the variable
#    'pathUntilProjectDirectory' inside that second set.
# FIRST SET:
verifyIfTwoArguments $@
pathUntilProjectDirectory=$1
projectName=$2
projectDirectory=$1/$2
# SECOND SET:
#verifyIfOneArgument $@
#pathUntilProjectDirectory="/home/herman/MyDrive/2_prog/" # change the value of this variable
#projectName=$1
#projectDirectory=$pathUntilProjectDirectory/$1
# << END OF A CONFIGURABLE BLOCK

projectDirectory=`echo $projectDirectory | sed 's/\/\//\//g'` # replace possible double // with single /

verifyIfCorrectPath $pathUntilProjectDirectory
verifyIfCorrectName $projectName
verifyIfProjectDirectoryExists $projectDirectory
createProjectDirectory $projectDirectory
createFilesStructure $projectDirectory $firstLevelPackageName $secondLevelPackageName $projectName
insertContentToMain $projectDirectory $firstLevelPackageName $secondLevelPackageName $projectName $gitCommitterName $gitCommitterSurname
insertContentToLoggerProperties $projectDirectory
insertContentToMainTest $projectDirectory $firstLevelPackageName $secondLevelPackageName $projectName
insertContentToPom $projectDirectory $firstLevelPackageName $secondLevelPackageName $projectName $projectURL
insertContentToReadme $projectDirectory $projectName
addGitignore $projectDirectory
addGitAttributes $projectDirectory
initGit $projectDirectory
setupGitCommitter $projectDirectory $gitCommitterName $gitCommitterSurname $gitCommitterEmail
showFinishMessage $projectName

# >> START OF A CONFIGURABLE BLOCK
# A. This block allows to open the project directory in the new
#    window with IntelliJ IDEA Community ('tryOpenWithIntelliJ')
#    or Visual Studio Code ('tryOpenWithVSCode') if installed.
# B. By default the described options are disabled by commenting out
#    the functions 'tryOpenWithIntelliJ' and 'tryOpenWithVSCode'. To enable one
#    of that options restore an appropriate function from the comment.
#tryOpenWithIntelliJ $projectName $projectDirectory
#tryOpenWithVSCode $projectName $projectDirectory
# << END OF A CONFIGURABLE BLOCK

echo

