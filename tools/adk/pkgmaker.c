/*
 * pkgmaker - create package meta-data for OpenADK buildsystem
 *
 * Copyright (C) 2010,2011 Waldemar Brodkorb <wbx@openadk.org>
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
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "sortfile.h"
#include "strmap.h"

#define MAXLINE 4096
#define MAXVALUE 168
#define MAXVAR 	64
#define MAXPATH 320
#define HASHSZ	32

static int nobinpkgs;

#define fatal_error(...) { \
	fprintf(stderr, "Fatal error. "); \
	fprintf(stderr, __VA_ARGS__); \
	fprintf(stderr, "\n"); \
	exit(1); \
}

static int parse_var_hash(char *buf, const char *varname, StrMap *strmap) {

	char *key, *value, *string;

	string = strstr(buf, varname);
	if (string != NULL) {
		string[strlen(string)-1] = '\0';
		key = strtok(string, ":=");
		value = strtok(NULL, "=\t");
		if (value != NULL)
			strmap_put(strmap, key, value);
		return(0);
	}
	return(1);
}

static int parse_var(char *buf, const char *varname, char *pvalue, char **result) {

	char *pkg_var;
	char *key, *value, *string;
	char pkg_str[MAXVAR];

	if ((pkg_var = malloc(MAXLINE)) != NULL)
		memset(pkg_var, 0, MAXLINE);
	else {
		perror("Can not allocate memory");
		exit(EXIT_FAILURE);
	}

	if (snprintf(pkg_str, MAXVAR, "%s:=", varname) < 0)
		perror("can not create path variable.");
	string = strstr(buf, pkg_str);
	if (string != NULL) {
		string[strlen(string)-1] = '\0';
		key = strtok(string, ":=");
		value = strtok(NULL, "=\t");
		if (value != NULL) {
			strncat(pkg_var, value, strlen(value));
			*result = strdup(pkg_var);
		} else {
			nobinpkgs = 1;
			*result = NULL;
		}
		free(pkg_var);
		return(0);
	} else {
		if (snprintf(pkg_str, MAXVAR, "%s+=", varname) < 0)
			perror("can not create path variable.");
		string = strstr(buf, pkg_str);
		if (string != NULL) {
			string[strlen(string)-1] = '\0';
			key = strtok(string, "+=");
			value = strtok(NULL, "=\t");
			if (pvalue != NULL)
				strncat(pkg_var, pvalue, strlen(pvalue));
			strncat(pkg_var, " ", 1);
			if (value != NULL)
				strncat(pkg_var, value, strlen(value));
			*result = strdup(pkg_var);
			free(pkg_var);
			return(0);
		}
	}
	free(pkg_var);
	return(1);
}

static int parse_var_with_pkg(char *buf, const char *varname, char *pvalue, char **result, char **pkgname, int varlen) {

	char *pkg_var, *check;
	char *key, *value, *string;

	if ((pkg_var = malloc(MAXLINE)) != NULL)
		memset(pkg_var, 0, MAXLINE);
	else {
		perror("Can not allocate memory");
		exit(EXIT_FAILURE);
	}

	check = strstr(buf, ":=");
	if (check != NULL) {
		string = strstr(buf, varname);
		if (string != NULL) {
			string[strlen(string)-1] = '\0';
			key = strtok(string, ":=");
			*pkgname = strdup(key+varlen);
			value = strtok(NULL, "=\t");
			if (value != NULL) {
				strncat(pkg_var, value, strlen(value));
				*result = strdup(pkg_var);
			}
			free(pkg_var);
			return(0);
		}
	} else {
		string = strstr(buf, varname);
		if (string != NULL) {
			string[strlen(string)-1] = '\0';
			key = strtok(string, "+=");
			value = strtok(NULL, "=\t");
			if (pvalue != NULL)
				strncat(pkg_var, pvalue, strlen(pvalue));
			strncat(pkg_var, " ", 1);
			if (value != NULL)
				strncat(pkg_var, value, strlen(value));
			*result = strdup(pkg_var);
			free(pkg_var);
			return(0);
		}
	}
	free(pkg_var);
	return(1);
}

/*
static void iter_debug(const char *key, const char *value, const void *obj) {
	fprintf(stderr, "HASHMAP key: %s value: %s\n", key, value);
}
*/

static int hash_str(char *string) {

	int i;
	int hash;

	hash = 0;
	for (i=0; i<(int)strlen(string); i++) {
		hash += string[i];
	}
	return(hash);
}

static void iter(const char *key, const char *value, const void *obj) {

	FILE *config, *section;
	int hash;
	char *valuestr, *pkg, *subpkg;
	char buf[MAXPATH];
	char infile[MAXPATH];
	char outfile[MAXPATH];

	valuestr = strdup(value);
	config = fopen("package/Config.in.auto", "a");
	if (config == NULL)
		fatal_error("Can not open file package/Config.in.auto");

	hash = hash_str(valuestr);
	snprintf(infile, MAXPATH, "package/pkglist.d/sectionlst.%d", hash);
	snprintf(outfile, MAXPATH, "package/pkglist.d/sectionlst.%d.sorted", hash);

	if (access(infile, F_OK) == 0) {
		valuestr[strlen(valuestr)-1] = '\0';
		fprintf(config, "menu \"%s\"\n", valuestr);
		sortfile(infile, outfile);
		/* avoid duplicate section entries */
		unlink(infile);
		section = fopen(outfile, "r");
		while (fgets(buf, MAXPATH, section) != NULL) {
			buf[strlen(buf)-1] = '\0';
			if (buf[strlen(buf)-1] == '@') {
				buf[strlen(buf)-1] = '\0';
				fprintf(config, "source \"package/%s/Config.in.manual\"\n", buf);
			} else {
				subpkg = strtok(buf, "|");
				subpkg[strlen(subpkg)-1] = '\0';
				pkg = strtok(NULL, "|");
				fprintf(config, "source \"package/pkgconfigs.d/%s/Config.in.%s\"\n", pkg, subpkg);
			}
		}
		fprintf(config, "endmenu\n\n");
		fclose(section);
	}
	fclose(config);
}

static char *tolowerstr(char *string) {

	int i;
	char *str;

	/* transform to lowercase variable name */
	str = strdup(string);
	for (i=0; i<(int)strlen(str); i++) {
		if (str[i] == '_')
			str[i] = '-';
		str[i] = tolower(str[i]);
	}
	return(str);
}

static char *toupperstr(char *string) {

	int i;
	char *str;
	
	/* transform to uppercase variable name */
	str = strdup(string);
	for (i=0; i<(int)strlen(str); i++) {
		if (str[i] == '+')
			str[i] = 'X';
		if (str[i] == '-')
			str[i] = '_';
		/* remove negation here, useful for package host depends */
		if (str[i] == '!')
			str[i] = '_';
		str[i] = toupper(str[i]);
	}
	return(str);
}


int main() {

	DIR *pkgdir, *pkglistdir;
	struct dirent *pkgdirp;
	FILE *pkg, *cfg, *menuglobal, *section;
	char hvalue[MAXVALUE];
	char buf[MAXPATH];
	char tbuf[MAXPATH];
	char path[MAXPATH];
	char spath[MAXPATH];
	char dir[MAXPATH];
	char variable[2*MAXVAR];
	char *key, *value, *token, *cftoken, *sp, *hkey, *val, *pkg_fd;
	char *pkg_name, *pkg_depends, *pkg_section, *pkg_descr, *pkg_url;
	char *pkg_cxx, *pkg_subpkgs, *pkg_cfline, *pkg_dflt, *pkg_multi;
	char *pkg_need_cxx, *pkg_need_java, *pkgname;
	char *pkg_host_depends, *pkg_arch_depends, *pkg_flavours, *pkg_choices, *pseudo_name;
	char *packages, *pkg_name_u, *pkgs;
	char *saveptr, *p_ptr, *s_ptr;
	int result;
	StrMap *pkgmap, *sectionmap;

	pkg_name = NULL;
	pkg_descr = NULL;
	pkg_section = NULL;
	pkg_url = NULL;
	pkg_depends = NULL;
	pkg_flavours = NULL;
	pkg_choices = NULL;
	pkg_subpkgs = NULL;
	pkg_arch_depends = NULL;
	pkg_host_depends = NULL;
	pkg_cxx = NULL;
	pkg_dflt = NULL;
	pkg_cfline = NULL;
	pkg_multi = NULL;
	pkg_need_cxx = NULL;
	pkg_need_java = NULL;
	pkgname = NULL;

	p_ptr = NULL;
	s_ptr = NULL;

	unlink("package/Config.in.auto");
	/* open global sectionfile */
	menuglobal = fopen("package/Config.in.auto.global", "w");
	if (menuglobal == NULL)
		fatal_error("global section file not writable.");

	/* read section list and create a hash table */
	section = fopen("package/section.lst", "r");
	if (section == NULL)
		fatal_error("section listfile is missing");

	sectionmap = strmap_new(HASHSZ);
	while (fgets(tbuf, MAXPATH, section) != NULL) {
		key = strtok(tbuf, "\t");
		value = strtok(NULL, "\t");
		strmap_put(sectionmap, key, value);
	}
	fclose(section);
	
	if (mkdir("package/pkgconfigs.d", S_IRWXU) > 0)
		fatal_error("creation of package/pkgconfigs.d failed.");
	if (mkdir("package/pkglist.d", S_IRWXU) > 0)
		fatal_error("creation of package/pkglist.d failed.");

	/* read Makefile's for all packages */
	pkgdir = opendir("package");
	while ((pkgdirp = readdir(pkgdir)) != NULL) {
		/* skip dotfiles */
		if (strncmp(pkgdirp->d_name, ".", 1) > 0) {
			if (snprintf(path, MAXPATH, "package/%s/Makefile", pkgdirp->d_name) < 0)
				fatal_error("can not create path variable.");
			pkg = fopen(path, "r");
			if (pkg == NULL)
				continue;

			/* skip manually maintained packages */
			if (snprintf(path, MAXPATH, "package/%s/Config.in.manual", pkgdirp->d_name) < 0)
				fatal_error("can not create path variable.");
			if (!access(path, F_OK)) {
				while (fgets(buf, MAXPATH, pkg) != NULL) {
					if ((parse_var(buf, "PKG_SECTION", NULL, &pkg_section)) == 0)
						continue;
				}

				memset(hvalue, 0 , MAXVALUE);
				result = strmap_get(sectionmap, pkg_section, hvalue, sizeof(hvalue));
				if (result == 1) {
					if (snprintf(spath, MAXPATH, "package/pkglist.d/sectionlst.%d", hash_str(hvalue)) < 0)
						fatal_error("can not create path variable.");
					section = fopen(spath, "a");
					if (section != NULL) {
						fprintf(section, "%s@\n", pkgdirp->d_name);
						fclose(section);
					}
				} else
					fatal_error("Can not find section description for package %s.",
							pkgdirp->d_name);
				
				fclose(pkg);
				continue;
			}

			nobinpkgs = 0;
			
			/* create output directories */
			if (snprintf(dir, MAXPATH, "package/pkgconfigs.d/%s", pkgdirp->d_name) < 0)
				fatal_error("can not create dir variable.");
			if (mkdir(dir, S_IRWXU) > 0)
				fatal_error("can not create directory.");

			/* allocate memory */
			hkey = malloc(MAXVAR);
			memset(hkey, 0, MAXVAR);
			memset(variable, 0, 2*MAXVAR);

			pkgmap = strmap_new(HASHSZ);

			/* parse package Makefile */
			while (fgets(buf, MAXPATH, pkg) != NULL) {
				/* just read variables prefixed with PKG */
				if (strncmp(buf, "PKG", 3) == 0) {
					if ((parse_var(buf, "PKG_NAME", NULL, &pkg_name)) == 0)
						continue;
					if (pkg_name != NULL)
						pkg_name_u = toupperstr(pkg_name);
					else
						pkg_name_u = toupperstr(pkgdirp->d_name);

					snprintf(variable, MAXVAR, "PKG_CFLINE_%s", pkg_name_u);
					if ((parse_var(buf, variable, pkg_cfline, &pkg_cfline)) == 0)
						continue;
					snprintf(variable, MAXVAR, "PKG_DFLT_%s", pkg_name_u);
					if ((parse_var(buf, variable, NULL, &pkg_dflt)) == 0)
						continue;
					if ((parse_var(buf, "PKG_HOST_DEPENDS", NULL, &pkg_host_depends)) == 0)
						continue;
					if ((parse_var(buf, "PKG_ARCH_DEPENDS", NULL, &pkg_arch_depends)) == 0)
						continue;
					if ((parse_var(buf, "PKG_DESCR", NULL, &pkg_descr)) == 0)
						continue;
					if ((parse_var(buf, "PKG_SECTION", NULL, &pkg_section)) == 0)
						continue;
					if ((parse_var(buf, "PKG_URL", NULL, &pkg_url)) == 0)
						continue;
					if ((parse_var(buf, "PKG_CXX", NULL, &pkg_cxx)) == 0)
						continue;
					if ((parse_var(buf, "PKG_NEED_CXX", NULL, &pkg_need_cxx)) == 0)
						continue;
					if ((parse_var(buf, "PKG_NEED_JAVA", NULL, &pkg_need_java)) == 0)
						continue;
					if ((parse_var(buf, "PKG_MULTI", NULL, &pkg_multi)) == 0)
						continue;
					if ((parse_var(buf, "PKG_DEPENDS", pkg_depends, &pkg_depends)) == 0)
						continue;
					if ((parse_var_with_pkg(buf, "PKG_FLAVOURS_", pkg_flavours, &pkg_flavours, &pkgname, 13)) == 0)
						continue;
					if ((parse_var_hash(buf, "PKGFD_", pkgmap)) == 0)
						continue;
					if ((parse_var_hash(buf, "PKGFS_", pkgmap)) == 0)
						continue;
					if ((parse_var_with_pkg(buf, "PKG_CHOICES_", pkg_choices, &pkg_choices, &pkgname, 12)) == 0)
						continue;
					if ((parse_var_hash(buf, "PKGCD_", pkgmap)) == 0)
						continue;
					if ((parse_var_hash(buf, "PKGCS_", pkgmap)) == 0)
						continue;
					if ((parse_var(buf, "PKG_SUBPKGS", pkg_subpkgs, &pkg_subpkgs)) == 0)
						continue;
					if ((parse_var_hash(buf, "PKGSD_", pkgmap)) == 0)
						continue;
					if ((parse_var_hash(buf, "PKGSS_", pkgmap)) == 0)
						continue;
					if ((parse_var_hash(buf, "PKGSC_", pkgmap)) == 0)
						continue;
				}
			}

			/* end of package Makefile parsing */
			if (fclose(pkg) != 0)
				perror("Failed to close file stream for Makefile");

#if 0
			if (pkg_name != NULL)
				fprintf(stderr, "Package name is %s\n", pkg_name);
			if (pkg_section != NULL)
				fprintf(stderr, "Package section is %s\n", pkg_section);
			if (pkg_descr != NULL)
				fprintf(stderr, "Package description is %s\n", pkg_descr);
			if (pkg_depends != NULL)
				fprintf(stderr, "Package dependencies are %s\n", pkg_depends);
			if (pkg_subpkgs != NULL)
				fprintf(stderr, "Package subpackages are %s\n", pkg_subpkgs);
			if (pkg_flavours != NULL && pkgname != NULL)
				fprintf(stderr, "Package flavours for %s are %s\n", pkgname, pkg_flavours);
			if (pkg_choices != NULL && pkgname != NULL)
				fprintf(stderr, "Package choices for %s are %s\n", pkgname, pkg_choices);
			if (pkg_url != NULL)
				fprintf(stderr, "Package homepage is %s\n", pkg_url);
			if (pkg_cfline != NULL)
				fprintf(stderr, "Package cfline is %s\n", pkg_cfline);
			if (pkg_multi != NULL)
				fprintf(stderr, "Package multi is %s\n", pkg_multi);

			strmap_enum(pkgmap, iter_debug, NULL);
#endif

			/* generate master source Config.in file */
			if (snprintf(path, MAXPATH, "package/pkgconfigs.d/%s/Config.in", pkgdirp->d_name) < 0)
				fatal_error("path variable creation failed.");
			fprintf(menuglobal, "source \"%s\"\n", path);
			/* recreating file is faster than truncating with w+ */
			unlink(path);
			cfg = fopen(path, "w");
			if (cfg == NULL)
				continue;

			pkgs = NULL;
			if (pkg_subpkgs != NULL)
				pkgs = strdup(pkg_subpkgs);

			fprintf(cfg, "config ADK_COMPILE_%s\n", toupperstr(pkgdirp->d_name));
			fprintf(cfg, "\ttristate\n");
			if (nobinpkgs == 0) {
				fprintf(cfg, "\tdepends on ");
				if (pkgs != NULL) {
					if (pkg_multi != NULL)
						if (strncmp(pkg_multi, "1", 1) == 0)
							fprintf(cfg, "ADK_HAVE_DOT_CONFIG || ");
					token = strtok(pkgs, " ");
					fprintf(cfg, "ADK_PACKAGE_%s", token);
					token = strtok(NULL, " ");
					while (token != NULL) {
						fprintf(cfg, " || ADK_PACKAGE_%s", token);
						token = strtok(NULL, " ");
					}
					fprintf(cfg, "\n");
				} else {
					fprintf(cfg, "ADK_PACKAGE_%s\n", toupperstr(pkgdirp->d_name));
				}
			} 
			fprintf(cfg, "\tdefault n\n");
			fclose(cfg);
			free(pkgs);

			/* skip packages without binary package output */
			if (nobinpkgs == 1)
				continue;

			/* generate binary package specific Config.in files */
			if (pkg_subpkgs != NULL)
				packages = tolowerstr(pkg_subpkgs);
			else
				packages = strdup(pkgdirp->d_name);

			token = strtok_r(packages, " ", &p_ptr);
			while (token != NULL) {
				strncat(hkey, "PKGSC_", 6);
				strncat(hkey, toupperstr(token), strlen(token));
				memset(hvalue, 0 , MAXVALUE);
				result = strmap_get(pkgmap, hkey, hvalue, sizeof(hvalue));
				memset(hkey, 0 , MAXVAR);
				if (result == 1)
					pkg_section = strdup(hvalue);

				strncat(hkey, "PKGSD_", 6);
				strncat(hkey, toupperstr(token), strlen(token));
				memset(hvalue, 0 , MAXVALUE);
				result = strmap_get(pkgmap, hkey, hvalue, sizeof(hvalue));
				memset(hkey, 0 , MAXVAR);
				if (result == 1)
					pkg_descr = strdup(hvalue);

				pseudo_name = malloc(MAXLINE);
				memset(pseudo_name, 0, MAXLINE);
				strncat(pseudo_name, token, strlen(token));
				while (strlen(pseudo_name) < 20)
					strncat(pseudo_name, ".", 1);

				if (snprintf(path, MAXPATH, "package/pkgconfigs.d/%s/Config.in.%s", pkgdirp->d_name, token) < 0)
					fatal_error("failed to create path variable.");

				/* create temporary section files */
				memset(hvalue, 0 , MAXVALUE);
				result = strmap_get(sectionmap, pkg_section, hvalue, sizeof(hvalue));
				if (result == 1) {
					if (snprintf(spath, MAXPATH, "package/pkglist.d/sectionlst.%d", hash_str(hvalue)) < 0)
						fatal_error("failed to create path variable.");
					section = fopen(spath, "a");
					if (section != NULL) {
						fprintf(section, "%s |%s\n", token, pkgdirp->d_name);
						fclose(section);
					}
				} else
					fatal_error("Can not find section description for package %s.", pkgdirp->d_name);

				unlink(path);
				cfg = fopen(path, "w");
				if (cfg == NULL)
					perror("Can not open Config.in file");

				if (pkg_need_cxx != NULL) {
					fprintf(cfg, "comment \"%s... %s (disabled, c++ missing)\"\n", token, pkg_descr);
					fprintf(cfg, "depends on !ADK_TOOLCHAIN_GCC_CXX\n\n");
				}
				fprintf(cfg, "config ADK_PACKAGE_%s\n", toupperstr(token));
				fprintf(cfg, "\tprompt \"%s. %s\"\n", pseudo_name, pkg_descr);
				fprintf(cfg, "\ttristate\n");
				if (pkg_multi != NULL)
					if (strncmp(pkg_multi, "1", 1) == 0)
						if (strncmp(toupperstr(token), toupperstr(pkgdirp->d_name), strlen(token)) != 0)
							fprintf(cfg, "\tdepends on ADK_PACKAGE_%s\n", toupperstr(pkgdirp->d_name));

				free(pseudo_name);

				/* print custom cf line */
				if (pkg_cfline != NULL) {
					cftoken = strtok_r(pkg_cfline, "@", &saveptr);
					while (cftoken != NULL) {
						fprintf(cfg, "\t%s\n", cftoken);
						cftoken = strtok_r(NULL, "@", &saveptr);
					}
				}

				/* add sub package dependencies */
				strncat(hkey, "PKGSS_", 6);
				strncat(hkey, toupperstr(token), strlen(token));
				memset(hvalue, 0, MAXVALUE);
				result = strmap_get(pkgmap, hkey, hvalue, sizeof(hvalue));
				if (result == 1) {
					val = strtok_r(hvalue, " ", &saveptr);
					while (val != NULL) { 
						if (strncmp(val, "kmod", 4) == 0)
							fprintf(cfg, "\tselect ADK_KPACKAGE_%s\n", toupperstr(val));
						else
							fprintf(cfg, "\tselect ADK_PACKAGE_%s\n", toupperstr(val));
						val = strtok_r(NULL, " ", &saveptr);
					}
				}
				memset(hkey, 0, MAXVAR);

				/* create package host dependency information */
				if (pkg_host_depends != NULL) {
					token = strtok(pkg_host_depends, " ");
					fprintf(cfg, "\tdepends on ");
					sp = "";
					while (token != NULL) {
						if(strncmp(token, "!", 1) == 0) {
							fprintf(cfg, "%s!ADK_HOST%s", sp, toupperstr(token));
							sp = " && ";
						} else {
							fprintf(cfg, "%sADK_HOST_%s", sp, toupperstr(token));
							sp = " || ";
						}
						token = strtok(NULL, " ");
					}
					fprintf(cfg, "\n");
				}

				/* create package target architecture dependency information */
				if (pkg_arch_depends != NULL) {
					token = strtok(pkg_arch_depends, " ");
					fprintf(cfg, "\tdepends on ");
					sp = "";
					while (token != NULL) {
						if(strncmp(token, "!", 1) == 0) {
							fprintf(cfg, "%s!ADK_LINUX%s", sp, toupperstr(token));
							sp = " && ";
						} else {
							fprintf(cfg, "%sADK_LINUX_%s", sp, toupperstr(token));
							sp = " || ";
						}
						token = strtok(NULL, " ");
					}
					fprintf(cfg, "\n");
				}

				/* create package dependency information */
				if (pkg_depends != NULL) {
					token = strtok(pkg_depends, " ");
					while (token != NULL) {
						if (strncmp(token, "kmod", 4) == 0)
							fprintf(cfg, "\tselect ADK_KPACKAGE_%s\n", toupperstr(token));
						else
							fprintf(cfg, "\tselect ADK_PACKAGE_%s\n", toupperstr(token));
						token = strtok(NULL, " ");
					}
					free(pkg_depends);
					pkg_depends = NULL;
				}

				if (pkg_need_cxx != NULL) {
					fprintf(cfg, "\tdepends on ADK_TOOLCHAIN_GCC_CXX\n");
				}
				if (pkg_need_java != NULL) {
					fprintf(cfg, "\tdepends on ADK_TOOLCHAIN_GCC_JAVA\n");
					pkg_need_java = NULL;
				}

				fprintf(cfg, "\tselect ADK_COMPILE_%s\n", toupperstr(pkgdirp->d_name));

				if (pkg_dflt != NULL) {
					fprintf(cfg, "\tdefault %s\n", pkg_dflt);
					pkg_dflt = NULL;
				} else {
					fprintf(cfg, "\tdefault n\n");
				}

				fprintf(cfg, "\thelp\n");
				fprintf(cfg, "\t  %s\n\n", pkg_descr);
				if (pkg_url != NULL)
					fprintf(cfg, "\t  WWW: %s\n", pkg_url);

				/* handle special C++ packages */
				if (pkg_cxx != NULL) {
					fprintf(cfg, "\nchoice\n");
					fprintf(cfg, "prompt \"C++ library to use\"\n");
					fprintf(cfg, "depends on ADK_COMPILE_%s\n\n", toupperstr(pkgdirp->d_name));
					fprintf(cfg, "default ADK_COMPILE_%s_WITH_STDCXX if ADK_TARGET_LIB_GLIBC || ADK_TARGET_LIB_EGLIBC\n", pkg_cxx);
					fprintf(cfg, "default ADK_COMPILE_%s_WITH_UCLIBCXX if ADK_TARGET_LIB_UCLIBC\n\n", pkg_cxx);
					fprintf(cfg, "config ADK_COMPILE_%s_WITH_STDCXX\n", pkg_cxx);
					fprintf(cfg, "\tbool \"GNU C++ library\"\n");
					fprintf(cfg, "\tselect ADK_PACKAGE_LIBSTDCXX\n\n");
					fprintf(cfg, "config ADK_COMPILE_%s_WITH_UCLIBCXX\n", pkg_cxx);
					fprintf(cfg, "\tbool \"uClibc++ library\"\n");
					fprintf(cfg, "\tselect ADK_PACKAGE_UCLIBCXX\n\n");
					fprintf(cfg, "endchoice\n");
					free(pkg_cxx);
					pkg_cxx = NULL;
				}

				/* package flavours */
				if (pkg_flavours != NULL) {
					token = strtok(pkg_flavours, " ");
					while (token != NULL) {
						fprintf(cfg, "\nconfig ADK_PACKAGE_%s_%s\n", pkgname, toupperstr(token));
						fprintf(cfg, "\tboolean ");
						strncat(hkey, "PKGFD_", 6);
						strncat(hkey, token, strlen(token));
						memset(hvalue, 0 , MAXVALUE);
						strmap_get(pkgmap, hkey, hvalue, sizeof(hvalue));
						memset(hkey, 0 , MAXVAR);
						pkg_fd = strdup(hvalue);

						fprintf(cfg, "\"%s\"\n", pkg_fd);
						fprintf(cfg, "\tdefault n\n");
						fprintf(cfg, "\tdepends on ADK_PACKAGE_%s\n", pkgname);
						strncat(hkey, "PKGFS_", 6);
						strncat(hkey, token, strlen(token));

						result = strmap_get(pkgmap, hkey, hvalue, sizeof(hvalue));
						if (result == 1) {
							val = strtok_r(hvalue, " ", &saveptr);
							while (val != NULL) { 
								if (strncmp(val, "kmod", 4) == 0)
									fprintf(cfg, "\tselect ADK_KPACKAGE_%s\n", toupperstr(val));
								else
									fprintf(cfg, "\tselect ADK_PACKAGE_%s\n", toupperstr(val));
								val = strtok_r(NULL, " ", &saveptr);
							}
						}
						memset(hkey, 0, MAXVAR);
						fprintf(cfg, "\thelp\n");
						fprintf(cfg, "\t  %s\n", pkg_fd);
						token = strtok(NULL, " ");
					}
					free(pkg_flavours);
					pkg_flavours = NULL;
				}

				/* package choices */
				if (pkg_choices != NULL) {
					fprintf(cfg, "\nchoice\n");
					fprintf(cfg, "prompt \"Package flavour choice\"\n");
					fprintf(cfg, "depends on ADK_PACKAGE_%s\n\n", pkgname);
					token = strtok(pkg_choices, " ");
					while (token != NULL) {
						fprintf(cfg, "config ADK_PACKAGE_%s_%s\n", pkgname, toupperstr(token));

						fprintf(cfg, "\tbool ");
						strncat(hkey, "PKGCD_", 6);
						strncat(hkey, token, strlen(token));
						memset(hvalue, 0 , MAXVALUE);
						strmap_get(pkgmap, hkey, hvalue, sizeof(hvalue));
						memset(hkey, 0 , MAXVAR);
						fprintf(cfg, "\"%s\"\n", hvalue);

						strncat(hkey, "PKGCS_", 6);
						strncat(hkey, token, strlen(token));
						memset(hvalue, 0, MAXVALUE);
						result = strmap_get(pkgmap, hkey, hvalue, sizeof(hvalue));
						if (result == 1) {
							val = strtok_r(hvalue, " ", &saveptr);
							while (val != NULL) { 
								if (strncmp(val, "kmod", 4) == 0)
									fprintf(cfg, "\tselect ADK_KPACKAGE_%s\n", toupperstr(val));
								else
									fprintf(cfg, "\tselect ADK_PACKAGE_%s\n", toupperstr(val));
								val = strtok_r(NULL, " ", &saveptr);
							}
						}
						memset(hkey, 0, MAXVAR);
						token = strtok(NULL, " ");
					}
					fprintf(cfg, "\nendchoice\n");
					free(pkg_choices);
					pkg_choices = NULL;
				}
				/* close file descriptor, parse next package */
				fclose(cfg);
				token = strtok_r(NULL, " ", &p_ptr);
			}

			/* end of package output generation */
			free(packages);
			packages = NULL;

			pkg_need_cxx = NULL;
			pkg_need_java = NULL;
			/* reset flags, free memory */
			free(pkg_name);
			free(pkg_descr);
			free(pkg_section);
			free(pkg_url);
			free(pkg_depends);
			free(pkg_flavours);
			free(pkg_choices);
			free(pkg_subpkgs);
			free(pkg_arch_depends);
			free(pkg_host_depends);
			free(pkg_cxx);
			free(pkg_dflt);
			free(pkg_cfline);
			free(pkg_multi);
			pkg_name = NULL;
			pkg_descr = NULL;
			pkg_section = NULL;
			pkg_url = NULL;
			pkg_depends = NULL;
			pkg_flavours = NULL;
			pkg_choices = NULL;
			pkg_subpkgs = NULL;
			pkg_arch_depends = NULL;
			pkg_host_depends = NULL;
			pkg_cxx = NULL;
			pkg_dflt = NULL;
			pkg_cfline = NULL;
			pkg_multi = NULL;

			strmap_delete(pkgmap);
			nobinpkgs = 0;
			free(hkey);
		}
	}


	/* create Config.in.auto */
	strmap_enum(sectionmap, iter, NULL);

	strmap_delete(sectionmap);
	fclose(menuglobal);
	closedir(pkgdir);

	/* remove temporary section files */
	pkglistdir = opendir("package/pkglist.d");
	while ((pkgdirp = readdir(pkglistdir)) != NULL) {
		if (strncmp(pkgdirp->d_name, "sectionlst.", 11) == 0) {
			if (snprintf(path, MAXPATH, "package/pkglist.d/%s", pkgdirp->d_name) < 0)
				fatal_error("creating path variable failed.");
			if (unlink(path) < 0)
				fatal_error("removing file failed.");
		}
	}
	closedir(pkglistdir);
	return(0);
}
