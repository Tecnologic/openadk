/*
 * depmaker - create package/Depends.mk for OpenADK buildsystem
 *
 * Copyright (C) 2010 Waldemar Brodkorb <wbx@openadk.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <ctype.h>
#include <dirent.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#define MAXLINE 512
#define MAXPATH 128

static int prefix = 0;

static int check_symbol(char *symbol) {

	FILE *config;
	char buf[MAXLINE];
	char *sym;
	int ret;

	if ((sym = malloc(strlen(symbol) + 2)) != NULL)
		memset(sym, 0, strlen(symbol) + 2);
	else {
		perror("Can not allocate memory.");
		exit(EXIT_FAILURE);
	}

	strncat(sym, symbol, strlen(symbol));
	strncat(sym, "=", 1);
	if ((config = fopen(".config", "r")) == NULL) {
		perror("Can not open file \".config\".");
		exit(EXIT_FAILURE);
	}

	ret = 1;
	while (fgets(buf, MAXLINE, config) != NULL) {
		if (strncmp(buf, sym, strlen(sym)) == 0)
			ret = 0;
	}

	free(sym);
	if (fclose(config) != 0)
		perror("Closing file stream failed");

	return(ret);
}

/*@null@*/
static char *parse_line(char *package, char *pkgvar, char *string, int checksym, int pprefix) {

	char *key, *value, *dep, *key_sym, *pkgdeps;
	char temp[MAXLINE];

	string[strlen(string)-1] = '\0';
	if ((key = strtok(string, ":=")) == NULL) {
		perror("Can not get key from string.");
		exit(EXIT_FAILURE);
	}

	if (checksym == 1) {
		/* extract symbol */
		if ((key_sym = malloc(MAXLINE)) != NULL)
			memset(key_sym, 0, MAXLINE);
		else {
			perror("Can not allocate memory.");
			exit(EXIT_FAILURE);
		}
		if (pprefix == 0) {
			if (snprintf(key_sym, MAXLINE, "ADK_PACKAGE_%s_", pkgvar) < 0)
				perror("Can not create string variable.");
		} else {
			if (snprintf(key_sym, MAXLINE, "ADK_PACKAGE_") < 0)
				perror("Can not create string variable.");
		}
			
		strncat(key_sym, key+6, strlen(key)-6);
		if (check_symbol(key_sym) != 0) {
			free(key_sym);
			return(NULL);
		}
		free(key_sym);
	}

	if ((pkgdeps = malloc(MAXLINE)) != NULL)
		memset(pkgdeps, 0, MAXLINE);
	else {
		perror("Can not allocate memory.");
		exit(EXIT_FAILURE);
	}

	value = strtok(NULL, "=\t");
	dep = strtok(value, " ");
	while (dep != NULL) {
		if (prefix == 0) {
			prefix = 1;
			if (snprintf(temp, MAXLINE, "%s-compile: %s-compile", package, dep) < 0)
				perror("Can not create string variable.");
		} else {
			if (snprintf(temp, MAXLINE, " %s-compile", dep) < 0)
				perror("Can not create string variable.");
		}
		strncat(pkgdeps, temp, strlen(temp));
		dep = strtok(NULL, " ");
	}
	return(pkgdeps);
}

int main() {

	DIR *pkgdir;
	struct dirent *pkgdirp;
	FILE *pkg;
	char buf[MAXLINE];
	char path[MAXPATH];
	char *string, *pkgvar, *pkgdeps, *tmp;
	int i;
	
	/* read Makefile's for all packages */
	pkgdir = opendir("package");
	while ((pkgdirp = readdir(pkgdir)) != NULL) {
		/* skip dotfiles */
		if (strncmp(pkgdirp->d_name, ".", 1) > 0) {
			if (snprintf(path, MAXPATH, "package/%s/Makefile", pkgdirp->d_name) < 0)
				perror("Can not create string variable.");
			pkg = fopen(path, "r");
			if (pkg == NULL)
				continue;
			
			/* transform to uppercase variable name */
			pkgvar = strdup(pkgdirp->d_name);
			for (i=0; i<(int)strlen(pkgvar); i++) {
				if (pkgvar[i] == '+')
					pkgvar[i] = 'X';
				if (pkgvar[i] == '-')
					pkgvar[i] = '_';
				pkgvar[i] = toupper(pkgvar[i]);
			}
			
			/* exclude manual maintained packages from package/Makefile */
			if (!(strncmp(pkgdirp->d_name, "eglibc", 6) == 0) &&
				!(strncmp(pkgdirp->d_name, "libc", 4) == 0 && strlen(pkgdirp->d_name) == 4) &&
				!(strncmp(pkgdirp->d_name, "libpthread", 10) == 0 && strlen(pkgdirp->d_name) == 10) &&
				!(strncmp(pkgdirp->d_name, "uclibc++", 8) == 0) &&
				!(strncmp(pkgdirp->d_name, "uclibc", 6) == 0) &&
				!(strncmp(pkgdirp->d_name, "glibc", 5) == 0)) {
				/* print result to stdout */
				printf("package-$(ADK_COMPILE_%s) += %s\n", pkgvar, pkgdirp->d_name); 
			}

			if ((pkgdeps = malloc(MAXLINE)) != NULL)
				memset(pkgdeps, 0, MAXLINE);
			else {
				perror("Can not allocate memory.");
				exit(EXIT_FAILURE);
			}
			prefix = 0;

			/* generate build dependencies */
			while (fgets(buf, MAXLINE, pkg) != NULL) {
				if ((tmp = malloc(MAXLINE)) != NULL)
					memset(tmp, 0 , MAXLINE);
				else {
					perror("Can not allocate memory.");
					exit(EXIT_FAILURE);
				}

				/* just read variables prefixed with PKG */
				if (strncmp(buf, "PKG", 3) == 0) {

					string = strstr(buf, "PKG_BUILDDEP:=");
					if (string != NULL) {
						tmp = parse_line(pkgdirp->d_name, pkgvar, string, 0, 0);
						if (tmp != NULL) {
							strncat(pkgdeps, tmp, strlen(tmp));
						}
					}

					string = strstr(buf, "PKG_BUILDDEP+=");
					if (string != NULL) {
						tmp = parse_line(pkgdirp->d_name, pkgvar, string, 0, 0);
						if (tmp != NULL)
							strncat(pkgdeps, tmp, strlen(tmp));
					}

					string = strstr(buf, "PKGFB_");
					if (string != NULL) {
						tmp = parse_line(pkgdirp->d_name, pkgvar, string, 1, 0);
						if (tmp != NULL)
							strncat(pkgdeps, tmp, strlen(tmp));
					}

					string = strstr(buf, "PKGCB_");
					if (string != NULL) {
						tmp = parse_line(pkgdirp->d_name, pkgvar, string, 1, 0);
						if (tmp != NULL)
							strncat(pkgdeps, tmp, strlen(tmp));
					}

					string = strstr(buf, "PKGSB_");
					if (string != NULL) {
						tmp = parse_line(pkgdirp->d_name, pkgvar, string, 1, 1);
						if (tmp != NULL) {
							strncat(pkgdeps, tmp, strlen(tmp));
						}
					}
				}
				free(tmp);
			}
			if (strlen(pkgdeps) != 0)
				printf("%s\n", pkgdeps);
			free(pkgdeps);
			free(pkgvar);
			if (fclose(pkg) != 0)
				perror("Closing file stream failed");
		}
	}
	if (closedir(pkgdir) != 0)
		perror("Closing directory stream failed");

	return(0);
}
