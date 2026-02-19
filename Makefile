STUID = ysyx_26020046
STUNAME = Bi RuiDe

# DO NOT modify the following code!!!
 
TRACER = tracer-ysyx
GITFLAGS = -q --author='$(TRACER) <tracer@ysyx.org>' --no-verify --allow-empty

YSYX_HOME = $(NEMU_HOME)/..
WORK_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
WORK_INDEX = $(YSYX_HOME)/.git/index.$(WORK_BRANCH)
TRACER_BRANCH = $(TRACER)

LOCK_DIR = $(YSYX_HOME)/.git/

# prototype: git_soft_checkout(branch)
define git_soft_checkout
	git checkout --detach -q && git reset --soft $(1) -q -- && git checkout $(1) -q --
endef

# prototype: git_commit(msg)
define git_commit
	-@flock $(LOCK_DIR) $(MAKE) -C $(YSYX_HOME) .git_commit MSG='$(1)'
	-@sync $(LOCK_DIR)
endef

.git_commit:
	-@while (test -e .git/index.lock); do sleep 0.1; done;               `# wait for other git instances`
	-@git branch $(TRACER_BRANCH) -q 2>/dev/null || true                 `# create tracer branch if not existent`
	-@cp -a .git/index $(WORK_INDEX)                                     `# backup git index`
	-@$(call git_soft_checkout, $(TRACER_BRANCH))                        `# switch to tracer branch`
	-@git add . -A --ignore-errors                                       `# add files to commit`
	-@(echo "> $(MSG)" && echo $(STUID) $(STUNAME) && uname -a && uptime `# generate commit msg`) \
	                | git commit -F - $(GITFLAGS)                        `# commit changes in tracer branch`
	-@$(call git_soft_checkout, $(WORK_BRANCH))                          `# switch to work branch`
	-@mv $(WORK_INDEX) .git/index                                        `# restore git index`

.clean_index:
	rm -f $(WORK_INDEX)

_default:
	@echo "Please run 'make' under subprojects."

.PHONY: .git_commit .clean_index _default

count:
	find . -type f \( -name "*.c" -o -name "*.h" \) -exec cat {} + | wc -l
countN:
	find . -type f \( -name "*.c" -o -name "*.h" \) -exec grep -vE '^$$' {} + | wc -l
Log:
	mkdir Log
gitLog:
	git log --graph --date-order --pretty=format:"%h%x09(%ad) %s" --date=iso --decorate > Log/gitLog.txt
# 	git log --graph --date-order --pretty=format:"%h (%ad) %s" --date=iso --decorate --shortstat > Log/gitLog.txt
	
# 	git log --graph --date-order --pretty=format:"%h (%ad) %s" --date=iso --shortstat --decorate | sed ':a;N;$!ba;s/\n */ /g' > Log/gitLog.txt
# 	git log --graph --date-order --pretty=format:"%h (%ad) %s" --date=iso --shortstat --decorate | awk '/^\*[^-]|^\|[^-]/ {printf "%s ", $$0; next} / files changed/ {printf "%s\n", $$0; next} {printf "%s ", $$0}' > Log/gitLog.txt



# 	git log --graph --date-order --pretty=reference --date=iso --decorate > Log/gitLog.txt
# 	git log --date=short --pretty=online --graph --decorate --date-order --shortstat > opt
# 	git log --date=short --pretty=short --decorate=full --no-indent --graph --decorate --date-order
# 	git log --graph --date-order --oneline --decorate > opt
# 参考预设+日期+装饰 + shortstat，awk拼接成一行
# 	git log --graph --date-order --pretty=reference --date=shor1t --decorate=full --abbrev=8 --shortstat | awk '/^[*| ]/ {if (buf) print buf; buf=$0} /files changed/ {buf=buf " | " $0} END {print buf}' > opt
gitLogU:
	git log --graph --date-order --pretty=format:"%h%x09(%ad) %s" --date=iso --decorate | grep -v "LAPTOP-3IAF75LK" > Log/gitLogU.txt
# 	git log --graph --date-order --pretty=reference --date=iso --decorate | grep -v "LAPTOP-3IAF75LK" > Log/gitLogU.txt
gitLogA:
# 	git log --oneline --graph --decorate --date-order --ALL > opt
	git log --graph --date-order --pretty=format:"%h%x09(%ad) %s" --date=iso --decorate --all > Log/gitLogA.txt
# 	git log --graph --date-order --pretty=reference --date=iso --decorate --all > Log/gitLogA.txt
gitLogAU:
	git log --graph --date-order --pretty=format:"%h%x09(%ad) %s" --date=iso --decorate --all | grep -v "LAPTOP-3IAF75LK" > Log/gitLogAU.txt
# 	git log --graph --date-order --pretty=reference --date=iso --decorate --all | grep -v "LAPTOP-3IAF75LK" > Log/gitLogAU.txt
log:Log gitLog gitLogU gitLogA gitLogAU

help:
	@echo "make run ARCH=riscv32-nemu -B CFLAGS_BUILD+="-DAUTO_RUN" mainargs=k"