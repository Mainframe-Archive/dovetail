TMP_DIR = tmp
LIB_DIR = priv

DOVECOT_MAJOR_VSN = 2.2
DOVECOT_MINOR_VSN = 16
DOVECOT_VSN       = $(DOVECOT_MAJOR_VSN).$(DOVECOT_MINOR_VSN)

DOVECOT_NAME      = dovecot-$(DOVECOT_VSN)
DOVECOT_TAR_NAME  = $(DOVECOT_NAME).tar.gz

DOVECOT_RELS      = http://www.dovecot.org/releases
DOVECOT_VSN_RELS  = $(DOVECOT_RELS)/$(DOVECOT_MAJOR_VSN)
DOVECOT_PREFIX    = $(LIB_DIR)/dovecot

.PHONY: all clean

all: $(DOVECOT_PREFIX)

clean:
	rm -r $(DOVECOT_PREFIX) $(TMP_DIR)

$(LIB_DIR):
	mkdir -p $@

$(TMP_DIR):
	mkdir -p $@

$(TMP_DIR)/$(DOVECOT_TAR_NAME).sig: $(TMP_DIR)
	curl "$(DOVECOT_VSN_RELS)/$(notdir $@)" -o $@

$(TMP_DIR)/$(DOVECOT_TAR_NAME): $(TMP_DIR)/$(DOVECOT_TAR_NAME).sig
	curl "$(DOVECOT_VSN_RELS)/$(notdir $@)" -o $@
	echo "WARNING: $@ not verified"

$(TMP_DIR)/$(DOVECOT_NAME): $(TMP_DIR)/$(DOVECOT_TAR_NAME)
	tar -xzf $< -C $(dir $@)

$(TMP_DIR)/$(DOVECOT_NAME)/Makefile: $(TMP_DIR)/$(DOVECOT_NAME)
	(cd $(dir $@) && ./configure --prefix=$(abspath $(DOVECOT_PREFIX)))

$(DOVECOT_PREFIX): $(TMP_DIR)/$(DOVECOT_NAME)/Makefile
	(cd $(dir $<) && make all install)


