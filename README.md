This is the tool I use to generate the exams for my Linux System and Network Administraion courses at the University of Sofia

Usually I generate the tests using the following snippet:
  for i in {1..20}; do ./gen.pl $i; done
