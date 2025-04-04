.PHONY: all

.ONESHELL:
.DEFAULT_GOAL       := all

SHELL               := /bin/bash
CUSTOM_TARGETS       =

PREFIX              ?= /usr

NAME                := $(notdir $(realpath .))
VERSION             := 0
UPDATED             := $(shell date +'%Y-%m-%d')
AUTHOR              := anon
CACHE_DIR           := .cache
DOCS_DIR            := docs
CONF_DIR            := conf
AWK_DIR             := awklib
FUNCS_DIR           := func
FILE_EXT            := .sh
INDENT              := $(shell echo -e "  ")
USAGE                = $(NAME) [OPTIONS]
OPTIONS_FILE        := options
MONOLITH             = _$(NAME)
BASE                := _init$(FILE_EXT)
SHBANG              := \#!/bin/bash
OPTIONS_ARRAY_NAME  := _o
FUNC_STYLE          := "() {"

config_mak          := config.mak
help_table          := $(CACHE_DIR)/help_table.txt
long_help           := $(CACHE_DIR)/long_help.md
getopt              := $(CACHE_DIR)/getopt
print_help          := $(CACHE_DIR)/print_help$(FILE_EXT)
print_version       := $(CACHE_DIR)/print_version$(FILE_EXT)

ifneq ($(wildcard $(config_mak)),)
  include config.mak
else
  config_mak    :=
endif

ifeq ($(wildcard $(OPTIONS_FILE)),)
  OPTIONS_FILE  :=
  help_table    :=
  long_help     :=
  getopt        :=
  print_help    :=
  print_version :=
endif

option_docs          = $(wildcard $(DOCS_DIR)/options/*)

function_files := $(wildcard $(FUNCS_DIR)/*)

# this hack writes 1 or 0 to the file .cache/got_func
# depending on existence of files in FUNC_DIR
# but it also makes sure to only update the file
# if the value has changed.
# this is needed for _init.sh (BASE) to know it needs
# to be rebuilt on this event.

ifneq ($(wildcard $(CACHE_DIR)/got_func),)
  ifneq ($(wildcard $(FUNCS_DIR)/*),)
    ifneq ($(file < $(CACHE_DIR)/got_func), 1)
      $(shell echo 1 > $(CACHE_DIR)/got_func)
    endif
  else
    ifneq ($(file < $(CACHE_DIR)/got_func), 0)
      $(shell echo 0 > $(CACHE_DIR)/got_func)
    endif
  endif
endif

$(CACHE_DIR)/got_func: | $(CACHE_DIR)/
	@$(info making $@)
	[[ -d $${tmp:=$(FUNCS_DIR)} ]] && tmp=1 || tmp=0
	echo $$tmp > $@

clean:
	rm -rf $(wildcard _*) $(CACHE_DIR) $(generated_functions)

$(BASE): $(getopt) $(print_help) $(print_version) $(CACHE_DIR)/got_func
	@$(info making $@)
	{
		printf '%s\n' '$(SHBANG)' '' 

		[[ -f $${pv:=$(print_version)} ]] \
			&& grep -vhE -e '^#!/' $(print_version) | sed '0,/2/s//$$\{__stderr:-2\}/'
		[[ -f $${ph:=$(print_help)} ]] \
			&& grep -vhE -e '^#!/' $(print_help)    | sed '0,/2/s//$$\{__stderr:-2\}/'

		echo

		[[ -d $${fd:=$(FUNCS_DIR)} ]] && {
			printf '%s\n' \
			'for ___f in "$$__dir/$(FUNCS_DIR)"/*; do' \
			'$(INDENT). "$$___f" ; done ; unset -v ___f'
		}

		echo
		
		[[ -f $${go:=$(getopt)} ]] && cat $(getopt)

		echo "((BASHBUD_VERBOSE)) && _o[verbose]=1"
		echo

		echo 'main "$$@"'
	} > $@

$(MONOLITH): $(print_version) $(NAME) $(print_help) $(function_files) $(getopt)
	@$(info making $@)
	{
		printf '%s\n' '$(SHBANG)' ''
		re='#bashbud$$'
		for f in $^; do
			# ignore files where the first line ends with '#bashbud'
			[[ $$(head -n1 $$f) =~ $$re ]] && continue	
			# ignore lines that ends with '#bashbud' (and shbangs)
			grep -vhE -e '^#!' -e '#bashbud$$' $$f
		done

		echo 'main "$$@"'
	} > $@
	
	chmod +x $@

# if a file in docs/options contains more than
# 2 lines, it will get added to the file .cache/long_help.md
# like this:
#   ### -s, --long-option ARG
#   text in docs/options/long-option after the first 2 lines
$(long_help): $(CACHE_DIR)/options_in_use $(option_docs)
	@$(info making $@)
	for option in budlabs $(file < $(CACHE_DIR)/options_in_use)
	do
		[[ ! -f $(DOCS_DIR)/options/$$option || $$(wc -l < $(DOCS_DIR)/options/$$option) -lt 2 ]] \
			&& continue
		printf '### '
		sed -r 's/\|\s*$$//g;s/^\s*//g' $(CACHE_DIR)/options/$$option
		echo
		tail -qn +3 "$(DOCS_DIR)/options/$$option"
		echo
	done > $@

$(CACHE_DIR)/synopsis.txt: $(OPTIONS_FILE) | $(CACHE_DIR)/
	@$(info making $@)
	sed 's/^/$(NAME) /g;s/*//g' $< > $@

$(help_table): $(long_help)
	@$(info making $@)
	for option in $$(cat $(CACHE_DIR)/options_in_use); do
		[[ -f $(CACHE_DIR)/options/$$option ]]  \
			&& frag=$$(cat $(CACHE_DIR)/options/$$option) \
			|| frag="$$option | "

		[[ -f $(DOCS_DIR)/options/$$option ]]  \
			&& desc=$$(head -qn1 $(DOCS_DIR)/options/$$option) \
			|| desc='short description  '

		paste <(echo "$$frag") <(echo "$$desc")
	done | tr -d '\t\\' > $@

$(print_version): $(config_mak) | $(CACHE_DIR)/
	@$(info making $@)
	echo $(SHBANG)
	fstyle=$(FUNC_STYLE)
	printf "__print_version$${fstyle}\n" > $@                          
	printf '%s\n'                                            \
		"$(INDENT)>&2 printf '%s\n' \\"                        \
		"$(INDENT)$(INDENT)'$(NAME) - version: $(VERSION)' \\" \
		"$(INDENT)$(INDENT)'updated: $(UPDATED) by $(AUTHOR)'" \
		"}"                                                    \
		"" >> $@

$(print_help): $(help_table) $(CACHE_DIR)/synopsis.txt 
	@$(info making $@)
	{
		echo $(SHBANG)
		fstyle=$(FUNC_STYLE)
		printf "__print_help$${fstyle}\n"
		echo "$(INDENT)cat << 'EOB' >&2  "
		if [[ options = "$(USAGE)" ]]; then
			cat $(CACHE_DIR)/synopsis.txt
			echo
		else 
			printf '%s\n' 'usage: $(USAGE)' ''
			echo
		fi
		cat $(help_table)
		printf '%s\n' 'EOB' '}'
	} > $@

$(CACHE_DIR)/:
	@$(info creating $(CACHE_DIR)/ dir)
	mkdir -p $(CACHE_DIR) $(CACHE_DIR)/options

$(FUNCS_DIR)/:
	@$(info creating $(FUNCS_DIR)/ dir)
	mkdir -p $(FUNCS_DIR)

$(CACHE_DIR)/options_in_use $(getopt) &: $(OPTIONS_FILE) | $(CACHE_DIR)/
	@$(info parsing $(OPTIONS_FILE))
	mkdir -p $(DOCS_DIR)/options
	gawk '
	BEGIN { RS=" |\\n" ; longest = length("version")}

	/./ {
		if (match($$0,/^\[?--([^][|[:space:]]+)(([|]-)(\S))?\]?$$/,ma)) 
		{
			gsub(/[][]/,"",$$0)
			opt_name = ma[1]
			if (length(opt_name) > longest)
				longest = length(opt_name)
			options[opt_name]["long_name"]  = opt_name
			if (ma[4] ~ /./) 
				options[opt_name]["short_name"] = ma[4]
		}

		else if (match($$0,/^\[?-(\S)([|]--([^][:space:]]+))?\]?$$/,ma))
		{
			gsub(/[][]/,"",$$0)
			opt_name = ma[1]
			if (ma[3] ~ /./)
			{
				opt_name = ma[3]
				options[opt_name]["short_name"] = ma[1]
				options[opt_name]["long_name"]  = opt_name
			}
			else
				options[opt_name]["short_name"] = opt_name

		}

		# ignore "Args" prefixed with an asterisk (*)
		else if (opt_name in options && !("arg" in options[opt_name]) && $$0 ~ /^[^*]/)
		{

			if ($$0 ~ /^[[]/)
				options[opt_name]["suffix"] = "::"
			else
				options[opt_name]["suffix"] = ":"

			gsub(/[][]/,"",$$0)
			if (length($$0) > longest_arg)
				longest_arg = length($$0)
			options[opt_name]["arg"] = $$0
		}
	}

	END {

		# sort array in alphabetical order
		# https://www.gnu.org/software/gawk/manual/html_node/Controlling-Scanning.html
		PROCINFO["sorted_in"] = "@ind_num_asc"

		for (o in options)
		{

			docfile = "$(DOCS_DIR)/options/" o
			docfile_fragment = "$(CACHE_DIR)/options/" o
			options_in_use = options_in_use " " o

			if(o ~ /./)
			{
				if ("short_name" in options[o])
				{
					out = "-" options[o]["short_name"]
					if ("long_name" in options[o])
						out = out ", "
					else
						out = out sprintf("%-" longest "s", " ")
				}
				else
					out = ""

				if ("long_name" in options[o]) {
					string_lenght = longest + ("short_name" in options[o] ? 0 : 4)
					out = out sprintf ("--%-" string_lenght "s", options[o]["long_name"])
				}
				
				if ("arg" in options[o])
					out = out sprintf (" %-" longest_arg "s", gensub (/\|/,"\\\\|","g",options[o]["arg"]))

				# 6 = -s, --
				# longest = longest long option name
				# 1 space after longoption
				# longest_arg + space
				fragment_length = 6+longest+1+longest_arg
				out = sprintf ("%-" fragment_length "s | ", out)
				print out > docfile_fragment

				if (system("[ ! -f " docfile " ]") == 0)
					print "short description  " > docfile
			}
					
			if ("long_name" in options[o])
			{
				long_options = long_options "," options[o]["long_name"]
				if ("suffix" in options[o])
					long_options = long_options options[o]["suffix"]
			}

			if ("short_name" in options[o])
			{
				short_options = short_options "," options[o]["short_name"]
				if ("suffix" in options[o])
					short_options = short_options options[o]["suffix"]
			}
		}

		print options_in_use > "$(CACHE_DIR)/options_in_use"

	  print ""
	  print "declare -A $(OPTIONS_ARRAY_NAME)"
	  print ""
		print "options=$$(getopt \\"
		print "  --name \"[ERROR]:" name "\" \\"
		if (short_options ~ /./)
			printf ("  --options \"%s\" \\\n", gensub(/^,/,"",1,short_options))
		printf ("  --longoptions \"%s\"  -- \"$$@\"\n", gensub(/^,/,"",1,long_options))
		print ") || exit 98"
		print ""
		print "eval set -- \"$$options\""
		print "unset -v options"
		print ""
		print "while true; do"
		print "  case \"$$1\" in"
		printf ("    --%-" longest+1 "s| -%s ) __print_help && exit ;;\n", "help", "h")
		printf ("    --%-" longest+1 "s| -%s ) __print_version && exit ;;\n", "version", "v")
		for (o in options)
		{
			if (o !~ /^(help|version)$$/)
			{
				if ("long_name" in options[o])
					printf ("    --%-" longest+1 "s", options[o]["long_name"])
				else
					printf ("%-" longest+7 "s", "")

				if ("short_name" in options[o])
					printf ("%s -%s ", ("long_name" in options[o] ? "|" : " "), options[o]["short_name"])
				else
					printf ("%s", "     ")

				if ("suffix" in options[o])
				{
					if (options[o]["suffix"] == "::")
						printf (") _o[%s]=$${2:-1} ; shift ;;\n", o)
					else
						printf (") _o[%s]=$$2 ; shift ;;\n", o)
				}
				else
					printf (") _o[%s]=1 ;;\n", o)
			}
		}

		print "    -- ) shift ; break ;;"
		print "    *  ) break ;;"
		print "  esac"
		print "  shift"
		print "done"
		print ""
	}
	' $(OPTIONS_FILE)                  \
			cache=$(CACHE_DIR)             \
			name=$(NAME) > $(getopt)

$(CACHE_DIR)/copyright.txt: $(config_mak)
	@$(info making $@)
	year_created=$(CREATED) year_created=$${year_created%%-*}
	year_updated=$$(date +'%Y')
	author="$(AUTHOR)" org=$(ORGANISATION)

	copy_text="Copyright (c) "

	((year_created == year_updated)) \
		&& copy_text+=$$year_created   \
		|| copy_text+="$${year_created}-$${year_updated}"

	[[ $$author ]] && copy_text+=", $$author"
	[[ $$org ]]    && copy_text+=" of $$org  "

	printf '%s\n' \
		"$$copy_text" "SPDX-License-Identifier: $(LICENSE)" > $@

.PHONY: check
check: all
	shellcheck $(MONOLITH)

other_maks := $(filter-out $(config_mak),$(wildcard *.mak))
-include $(other_maks)

# by having all:  last, it is possible to add CUSTOM_TARGETS
# in 'other_maks', and have them automatically apply
all: $(CUSTOM_TARGETS) $(MONOLITH) $(BASE)
