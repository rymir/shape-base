REBAR=./rebar
RELX=./relx
DIALYZER=$(shell which dialyzer)
ifeq ($(DIALYZER),)
	$(error "Dialyzer not available on this system")
endif

DEPSOLVER_PLT=./.plt

RELEASES = \
	shape \
	shape2

all: deps compile

deps:
	@$(REBAR) get-deps

compile: deps
	@$(REBAR) compile

$(DEPSOLVER_PLT):
	@$(DIALYZER) --output_plt $(DEPSOLVER_PLT) --build_plt \
		--apps erts kernel stdlib crypto public_key -r deps

dialyze: $(DEPSOLVER_PLT) compile
	@$(DIALYZER) --plt $(DEPSOLVER_PLT) --src apps/*/src \
		-Wunmatched_returns -Werror_handling -Wrace_conditions \
		-Wno_undefined_callbacks

test: compile
	@$(REBAR) -r -v eunit skip_deps=true verbose=0
	ct_run -dir apps/*/itest -pa ebin -verbosity 0 -logdir .ct/logs \
		-erl_args +K true +A 10

%.test: compile PHONY
	@$(REBAR) -r -v eunit skip_deps=true verbose=0 apps=$*
	@ct_run -dir apps/$*/itest -pa ebin -verbosity 0 -logdir .ct/logs \
		-erl_args +K true +A 10

doc:
	@$(REBAR) -r doc skip_deps=true

validate: dialyze test

rel: $(addsuffix .rel, $(RELEASES))

%.rel: clean validate PHONY
	@$(RELX) release -c relx-$*.config tar

clean:
	@$(REBAR) -r clean

relclean: $(addsuffix .relclean, $(RELEASES))

%.relclean: clean PHONY
	@rm -rvf ./_rel/$*

deepclean: relclean
	@rm $(DEPSOLVER_PLT)
	@rm -rvf ./deps/*
	@git clean -d -x -ff

PHONY:
	@true

.PHONY: PHONY all deps compile dialyze test doc validate rel clean \
	relclean deepclean
