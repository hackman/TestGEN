#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(strftime);
use DBD::Pg;
use PDF::Reuse;
use utf8;

#
# ./generate-tests.pl [variant]
#

$|=1;

sub logger {
	print 'Error: ' . $_[0] ."\n" if defined($_[0]);
}

# DataBase details
my $pguser = 'postgres';
my $pgpass = '';
my $pgdb = 'DBI:Pg:database=smal;host=localhost;port=5432';
my $pgconn = DBI->connect_cached( $pgdb, $pguser, $pgpass, { PrintError => 1, AutoCommit => 1 }) or die("$DBI::errstr\n");
my $schema = '2009-2010';
# for which year is this test
my $test_year = strftime('%Y', localtime(time));
# Which of the two tests: 1 or 2
my $which_test = '1';

# define which test we are going to generate, first or second
my $first_test = 'true';

# which variant is this
my $variant = '1';
$variant = $ARGV[0] if (defined($ARGV[0]) && $ARGV[0] =~ /^[0-9]+$/);
my $filename = "test$which_test-variant$variant";

$pgconn->{pg_enable_utf8}=1;

# how many questions will our test have?
my $test_qcount = 50;
# this hash is used for the generation of random questions
my @ques = ();
my %q_check = ();
# 
my $q=0;

# @ques structure
# [0][0] - question id
# [0][1] - question text
# [0][3] - answers array [0-4]
# [0][4] - right answer location

# get 50 random questions from the DB
my $get_question   = $pgconn->prepare(sprintf('SELECT id,question FROM "%s".questions WHERE first_test ORDER BY random() LIMIT 50', $schema)) or logger($DBI::errstr);
# get the right answer
my $right_answer  = $pgconn->prepare(sprintf('SELECT answer FROM "%s".right_answers WHERE q_id = ?', $schema)) or logger($DBI::errstr);
# get the wrong answers, randomly ordered
my $wrong_asnwers = $pgconn->prepare(sprintf('SELECT answer FROM "%s".wrong_answers WHERE q_id = ? ORDER BY random()', $schema)) or logger($DBI::errstr);

# populate the questions array
$get_question->execute() or logger($DBI::errstr);
while (my @ret = $get_question->fetchrow_array) {
	$ques[$q][0] = $ret[0];
	$ques[$q][1] = $ret[1];
	$q++;
}
# add the answers for the questions
for($q = 0; $q < $test_qcount; $q++) {
	my $a = 0;
	my $right_answer_location = 0 + int(rand(5));	# choose a random location for the right answer

	# select the right answer
	$right_answer->execute($ques[$q][0]);
	$ques[$q][3][$right_answer_location] = $right_answer->fetchrow_array;
	# select thw worng answers
	$wrong_asnwers->execute($ques[$q][0]);

	while(my @ret = $wrong_asnwers->fetchrow_array) {
		if ($a == $right_answer_location) {
			$a++;
		}
		$ques[$q][3][$a] = $ret[0];
		$a++;
	}
	$ques[$q][4] = $right_answer_location;
}

%q_check = ();
my $d = 1 + int(rand($test_qcount));
for ($q = 0; $q < $test_qcount; $q++) {
	while (exists($q_check{$d})) { $d = 1 + int(rand($test_qcount)); }
	$q_check{$d} = 1;
	my $a1 = $q;
	my $a2 = $d;
	if ($q < 10) {
		$a1 = "0$q";
	}
	if ($d < 10) {
		$a2 = "0$d";
	}
# For debug purposes
#	print "Num: $a1 Q: $a2 Q_id: $ques[$q][0] Right answer: $ques[$q][4]\n";
}

# Print out the generated list

#my @abrv = ( 'a', 'b', 'c', 'd', 'e' );
#for ($q = 0; $q < $test_qcount; $q++ ) {
#	printf " %d. (%d) %s\n", $q+1, $ques[$q][0], $ques[$q][1];
#	for (my $j = 0; $j < 5; $j++) {
#		if (defined($ques[$q][3][$j])) {
#			printf "   %s) %s\n", $abrv[$j], $ques[$q][3][$j];
#		}
#	}
#}

my $page_count = 1;
my $last_line = 640;
my @abrv = ( 'a', 'b', 'c', 'd', 'e' );

sub page_check {
	my $last_pos = $_[0];
	my $page_count = $_[1];
# 	print 'Page: '.${$page_count}.' Line: '.${$last_pos}."\n";
	${$last_pos} -= 16;
	if (${$last_pos} < 40) {
		if (${$page_count} == 1) {
			prAdd("0.0 0.0 0.0 RG\n");
			prAdd("9.0 9.0 9.0 rg\n");
			for my $l (1..25) {
				my $pos = ($l * 18) + 20;
				prAdd("$pos 700 18 20 re\n");
				prAdd("$pos 660 18 20 re\n");
			}
			prAdd("B\n");
		}

		${$last_pos} = 780;
		prPage();
		${$page_count}++;
		prText(520,800,'Page '.${$page_count});
	}
}

prFile("$filename.pdf");
prTTFont('/usr/share/fonts/arial.ttf');
prText(35,800,"Linux System & Network Administration");
prText(340,800,"TEST $which_test   $test_year");
prText(522,800,"Page $page_count");
prText(35,780,"Full Name: ______________________________________________________________________");
prText(35,760,"Faculty No:__________   Year:___  Gender:___");
prText(510,760,"Variant: $variant");
for my $l (1..25) {
	my $pos = ($l * 18) + 24;
	prText($pos,724,$l);
	prText($pos,684,$l+25);
}

prFontSize('10');


# populate the questions
for ($q = 0; $q < $test_qcount; $q++) {
	my $question = $ques[$q][1];

	page_check(\$last_line,\$page_count);

	my $q_len = length($question);
	if ($q_len > 102) {
		my @lines = split /\n/, $question;
		for (my $l=0;$l<=$#lines;$l++) {
			$lines[$l] =~ s/\n/ /g;
			if ($l==0) {
				prText(35,$last_line,sprintf('%d. %s', $q+1, $lines[$l]));
			} else {
				prText(35,$last_line,$lines[$l]) if ($lines[$l] !~ /^[\s|\n]*$/);
			}
			page_check(\$last_line,\$page_count);
		}
	} else {
		prText(35,$last_line,sprintf('%d. %s', $q+1, $question));
	}

	for (my $j = 0; $j < 5; $j++) {
		if (defined($ques[$q][3][$j])) {
			page_check(\$last_line,\$page_count);
			prText(35,$last_line,sprintf("  %s) %s", $abrv[$j], $ques[$q][3][$j]));
		}
	}
}
prEnd();
prFile("$filename-asnwares.pdf");
prTTFont('/usr/share/fonts/arial.ttf');
prText(510,760,"Variant: $variant");
for my $l (1..25) {
	my $pos = ($l * 18) + 24;
	prText($pos,724,$l);
	prText($pos,684,$l+25);
}

# print the right answers :)
my $tcount = 1;
for ($q = 0; $q < $test_qcount; $q++) {
#	next if (!defined($ques[$q][4]));
	my $right = $abrv[$ques[$q][4]];
# 	printf("%2d: %s \n",$tcount, $right);
 	prAdd("q 40 717 m 490 717 l S Q");
 	prAdd("q 40 698 m 490 698 l S Q");
 	prAdd("q 40 677 m 490 677 l S Q");
 	prAdd("q 40 658 m 490 658 l S Q");
 	prAdd("q 490 698 m 490 717 l S Q");
 	prAdd("q 490 658 m 490 677 l S Q");
 	if ($tcount <= 25) {
		my $pos = ($tcount * 18) + 24;
		my $pos2 =  $pos - 2;
		prAdd("q $pos2 698 m $pos2 717 l S Q");
		prText($pos,702,$right);
	} else {
		my $pos = (($tcount - 25) * 18) + 24;
		my $pos2 = $pos - 2;
		prAdd("q $pos2 658 m $pos2 677 l S Q");
		prText($pos,662,$right);
	}

	$tcount++;
}

#for my $l (1..25) {
# 	my $pos = ($l * 18) + 20;
# 	prAdd("$pos 700 18 20 re\n");
# 	prAdd("$pos 660 18 20 re\n");
#}
prAdd("B\n");

prEnd();
