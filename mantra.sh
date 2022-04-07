#!/bin/bash

# @author Herman Ciechanowiec, herman@ciechanowiec.eu
# This program is a Shell script for Linux Ubuntu. Its purpose is to create a 
# template Java project with basic functionality out of the box.
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
	if [[ ! "$1" =~ ^[a-z]{1}([a-z0-9]*)$ ]]
	then
	        printf "\e[1;91m[ERROR]:\e[0m The provided project name may consist only of lower case letters and numbers; the first character should be a letter. This condition hasn't been met and the script has stopped.\n\n"
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
	mkdir -p $1/src/{main/{java/eu/ciechanowiec/$2,resources},test/java/eu/ciechanowiec/$2}
	touch $1/src/main/java/eu/ciechanowiec/$2/Main.java
	touch $1/src/main/resources/tinylog.properties
	touch $1/src/test/java/eu/ciechanowiec/$2/MainTest.java
	touch $1/pom.xml
	touch $1/README.md
	printf "\e[1;96m[STATUS]:\e[0m The following file structure for the project has been created:\n"
	tree $1
}

insertContentToMain () {
mainFile=$1/src/main/java/eu/ciechanowiec/$2/Main.java
cat > $mainFile << EOF
package eu.ciechanowiec.$2;

import org.tinylog.Logger;

/**
 * @author $3 $4
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
mainTestFile=$1/src/test/java/eu/ciechanowiec/$2/MainTest.java
cat > $mainTestFile << EOF
package eu.ciechanowiec.$2;

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
pomFile=$1/pom.xml
projectName=$2
cat > $pomFile << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>eu.ciechanowiec.$projectName</groupId>
  <artifactId>$projectName</artifactId>
  <version>1.0</version>
  <packaging>jar</packaging>

  <name>$projectName</name>
  <description>Java Program</description>
  <url>https://ciechanowiec.eu/</url>

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
              <mainClass>eu.ciechanowiec.$projectName.Main</mainClass>
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
touch $1/.gitignore
gitignoreFile=$1/.gitignore
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

setupGitCommitter() {
	currentDirectory=`pwd`
	cd $1
	git config user.name "$2 $3"
	git config user.email $4
	printf "\e[1;96m[STATUS]:\e[0m Git committer fot this project has been set up: $2 $3 <$4>.\n"
	cd $currentDirectory
}

showFinishMessage () {
	projectName=$1
	printf "\e[1;92m[SUCCESS]:\e[0m The project \e[3m$projectName\e[0m has been created.\n"
}

tryOpenWithVSCode () {
	projectName=$1
	projectDirectory=$2
	if command code -v &> /dev/null # Checks whether VSCode CLI command ('code') exists
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
				kill -9 $PPID # Kill the terminal after opening VSCode
			fi
		done
  fi
}

tryOpenWithIntelliJ () {
	projectName=$1
	projectDirectory=$2
	if [ -f /snap/intellij-idea-community/current/bin/idea.sh ] # Checks whether IntelliJ IDEA native run script exists
  then
    while true
    do
      printf "\e[1;93m[INTELLIJ IDEA]:\e[0m Open the project \e[3m$projectName\e[0m with IntelliJ IDEA?\ny/n: "
      read answer
      if [ $answer = 'n' ] || [ $answer = 'N' ]
      then
        echo
        exit
      elif [ $answer = 'y' ] || [ $answer = 'Y' ]
      then
        echo
        nohup /snap/intellij-idea-community/current/bin/idea.sh $projectDirectory 2>/dev/null &
        sleep 13 # Let terminal have time to open IntelliJ IDEA
        kill -9 $PPID # Kill the terminal after opening IntelliJ IDEA
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

gitCommitterName="Herman"
gitCommitterSurname="Ciechanowiec"
gitCommitterEmail="herman@ciechanowiec.eu"

pathUntilProjectDirectory=$1
projectName=$2
projectDirectory=$1/$2
projectDirectory=`echo $projectDirectory | sed 's/\/\//\//g'` #replaces possible double // with single /

verifyIfCorrectPath $pathUntilProjectDirectory
verifyIfCorrectName $projectName
verifyIfProjectDirectoryExists $projectDirectory
createProjectDirectory $projectDirectory
createFileStructure $projectDirectory $projectName
insertContentToMain $projectDirectory $projectName $gitCommitterName $gitCommitterSurname
insertContentToLoggerProperties $projectDirectory
insertContentToMainTest $projectDirectory $projectName
insertContentToPom $projectDirectory $projectName
insertContentToReadme $projectDirectory $projectName
addGitignore $projectDirectory
addGitattributes $projectDirectory
initGit $projectDirectory
setupGitCommitter $projectDirectory $gitCommitterName $gitCommitterSurname $gitCommitterEmail
showFinishMessage $projectName
#tryOpenWithVSCode $projectName $projectDirectory
#tryOpenWithIntelliJ $projectName $projectDirectory
echo
