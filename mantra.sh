#!/bin/bash

# @author Herman Ciechanowiec, herman@ciechanowiec.eu
# This program is a Shell script for Linux Ubuntu. Its purpose is to create a 
# template Java project with Maven, JUnit and Git functionality out of the box.
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
		printf "\e[1;91m[ERROR]:\e[0m 'tree' package which is needed to run the script hasn't been detected and the script has stopped. Try to install 'tree' package using command 'sudo apt-get install tree'.\n\n"
        	exit
	fi
}

verifyIfGitExists () {
        if ! command git --version &> /dev/null
        then
                printf "\e[1;91m[ERROR]:\e[0m 'git' package which is needed to run the script hasn't been detected and the script has stopped. Try to install 'git' package using command 'sudo apt-get install git'.\n\n"
                exit
        fi
}

verifyIfTwoArguments () {	
	if [ $# != 2 ]
	then
	        printf "\e[1;91m[ERROR]:\e[0m The script must be provided with two arguments. The first one should be an absolute path where the project directory is to be created and the second one should be the project name. This condition hasn't been met and the script has stopped.\n\n"
		exit
	fi
}

verifyIfCorrectPath () {
	if [[ ! "$1" =~ ^\/.* ]]
	then
        	printf "\e[1;91m[ERROR]:\e[0m As the first argument for the script an absolute path where the project directory is to be created should be provided. This condition hasn't been met and the script has stopped.\n\n"
	        exit
	fi
}

verifyIfCorrectName () {
	if [[ ! "$1" =~ ^[a-z]{1}([a-z_0-9]*)$ ]]
	then
	        printf "\e[1;91m[ERROR]:\e[0m The provided project name may consist only of lower case alphanumericals and _ (underscore); the first character should be a letter. This condition hasn't been met and the script has stopped.\n\n"
	        exit
	fi
}

verifyIfProjectDirectoryExists () {
        if [ -d $1 ]
        then
                printf "\e[1;91m[ERROR]:\e[0m The project already exists in \e[3m$1\e[0m. The script has stopped.\n\n"
		exit
        fi
}

createProjectDirectory () {
	mkdir -p $1
	printf "\e[1;96m[STATUS]:\e[0m The project directory \e[3m$1\e[0m has been created.\n"
}

createFileStructure () {
	mkdir -p $1/src/{main/{java/com,resources},test/java/com}
	touch $1/src/main/java/com/Main.java
	touch $1/src/test/java/com/MainTest.java
	touch $1/pom.xml
	touch $1/README.md
	printf "\e[1;96m[STATUS]:\e[0m The following file structure for the project has been created:\n"
	tree $1
}

insertContentToMain () {
mainFile=$1/src/main/java/com/Main.java
cat > $mainFile << EOF
package com;

public class Main {

    public static void main(String[] args) {
        System.out.println("Hello, Universe!");
    }
}	
EOF
printf "\e[1;96m[STATUS]:\e[0m Default Java-content has been added to \e[3mMain.java\e[0m.\n" 
}

insertContentToMainTest () {
mainTestFile=$1/src/test/java/com/MainTest.java
cat > $mainTestFile << EOF
package com;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class MainTest {

    @Test
    public void sampleTrueTest() {
        assertTrue(true);
    }
}
EOF
printf "\e[1;96m[STATUS]:\e[0m Default JUnit-content has been added to \e[3mMainTest.java\e[0m.\n"	
}

insertContentToPom () {
pomFile=$1/pom.xml
projectName=$2
cat > $pomFile << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.$projectName</groupId>
    <artifactId>$projectName</artifactId>
    <version>1.0</version>
    <packaging>jar</packaging>

    <name>$projectName</name>
    <description>Java Program</description>
    <url>https://example.com/</url>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter-api</artifactId>
            <version>5.8.2</version>
            <scope>test</scope>
        </dependency>
        <dependency>
          <groupId>org.junit.jupiter</groupId>
          <artifactId>junit-jupiter-engine</artifactId>
          <version>5.8.2</version>
          <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-jar-plugin</artifactId>
          <version>3.2.2</version>
          <configuration>
            <archive>
              <manifest>
                <addClasspath>true</addClasspath>
                <mainClass>com.Main</mainClass>
              </manifest>
            </archive>
          </configuration>
        </plugin>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-surefire-plugin</artifactId>
          <version>3.0.0-M5</version>
        </plugin>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-failsafe-plugin</artifactId>
            <version>3.0.0-M5</version>
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
touch $1/.gitignore
gitignoreFile=$1/.gitignore
cat > $gitignoreFile << EOF
# All files with .class extension:
*.class

# All files with .log extension + all files and directories named 'logs':
*.log
**/logs

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
	   \055 all files with \e[3m.log\e[0m extension
	   \055 all files and directories named \e[3mlogs\e[0m
	   \055 \e[3mtarget\e[0m directory located directly in the project directory
	   \055 all files and directories which names start with \e[3m. (dot)\e[0m,
	     except \e[3m.git\e[0m, \e[3m.gitattributes\e[0m and \e[3m.gitignore\e[0m\n"
}

addGitattributes () {
touch $1/.gitattributes
gitattributesFile=$1/.gitattributes
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
	git init $projectDirectory > /dev/null
	printf "\e[1;96m[STATUS]:\e[0m Git repository has been initialized.\n"
}

showFinishMessage () {	
	projectName=$1
	printf "\e[1;92m[SUCCESS]:\e[0m The project \e[3m$projectName\e[0m has been created.\n"
}

tryOpenWithVSCode () {
	projectName=$1
	projectDirectory=$2	
	if command code -v &> /dev/null
        then
		while true
		do
	                printf "\e[1;93m[VSCODE]:\e[0m Open the project \e[3m$projectName\e[0m with VS Code?\ny/n: "
			read answer
			if [ $answer = 'n' ] || [ $answer = 'N' ]
			then
				echo
				exit
			elif [ $answer = 'y' ] || [ $answer = 'Y' ]
			then
				echo			
				code -n $projectDirectory	
				exit
			fi
		done                              
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
verifyIfTwoArguments $@

pathUntilProjectDirectory=$1
projectName=$2
projectDirectory=$1/$2
projectDirectory=`echo $projectDirectory | sed 's/\/\//\//g'`

verifyIfCorrectPath $pathUntilProjectDirectory
verifyIfCorrectName $projectName
verifyIfProjectDirectoryExists $projectDirectory
createProjectDirectory $projectDirectory
createFileStructure $projectDirectory
insertContentToMain $projectDirectory
insertContentToMainTest $projectDirectory
insertContentToPom $projectDirectory $projectName
insertContentToReadme $projectDirectory $projectName
addGitignore $projectDirectory
addGitattributes $projectDirectory
initGit $projectDirectory
showFinishMessage $projectName
tryOpenWithVSCode $projectName $projectDirectory
echo
