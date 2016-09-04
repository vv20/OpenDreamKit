REVIEW_2016_06_DELIVERABLES=WP1/D1.1 WP1/D1.2 WP2/D2.1 WP3/D3.1 WP4/D4.1 WP4/D4.2 WP5/D5.1 WP6/D6.1
REVIEW_2017_03_DELIVERABLES=WP5/D5.3
DELIVERABLES=$(REVIEW_2016_06_DELIVERABLES) $(REVIEW_2017_03_DELIVERABLES)
REPORTS=$(DELIVERABLES:%=%/report.pdf)

reports: $(REPORTS)
reports.zip: $(REPORTS)
	rm -rf /tmp/reports
	mkdir /tmp/reports
	for deliverable in $(REPORTS); do cp $$deliverable/report.pdf /tmp/reports/`basename $$deliverable`.pdf; done
	zip -r --junk-paths reports.zip /tmp/reports

%/github-issue-description.md:
	(issue=`python bin/get_issue $*/report.tex`; echo "# Deliverable description, as taken from Github issue's #$$issue on `date -I` {.notoc}\n"; python bin/get_issue_body $$issue) > $@

# For some pandoc does not support both options {.notoc .unumbered}. So we force the section to be a section* ...
%.tex: %.md
	sed -e 's/- \[[xX]\]/- $$\\checkmark$$/; s! \([^ ]*[a-z]\)#\([0-9][0-9]*\)! [\1#\2](https://github.com/\1/issues/\2)!g; s!\([^a-z]\)#\([0-9]*[0-9]\)!\1[#\2](https://github.com/OpenDreamKit/OpenDreamKit/issues/\2)!g;' $< | pandoc --toc-depth=1 -f markdown_github+tex_math_dollars+header_attributes -t latex | sed -e 's/\\section/\\section*/' > $@

%/report.pdf: %/report.tex %/github-issue-description.tex Proposal/LaTeX-proposal/deliverablereport.cls
	cd `dirname $<`; file=`basename $<`; pdflatex $$file; bibtex $$file; pdflatex $$file; pdflatex $$file

WP3/D3.1/report.pdf: WP3/D3.1/status-report.tex

.SECONDARY:

clean:
	-rm $(REVIEW_2016_06_DELIVERABLES:%=%/report.pdf)

real-clean: clean
	-rm $(REVIEW_2016_06_DELIVERABLES:%=%/github-issue-description.md)
	-rm $(REVIEW_2016_06_DELIVERABLES:%=%/github-issue-description.tex)


