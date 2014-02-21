#!/usr/bin/perl
#
#-------------------------------------------------------------------------
# snp-convert-kgp-rs.pl
#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------
# Richard Duncan
# Emory University, School of Medicine
# Department of Human Genetics
# richard.duncan@emory.edu
#
#-------------------------------------------------------------------------
# sample commands:
#-------------------------------------------------------------------------
#./snp-convert-kgp-rs.pl --help
#./snp-convert-kgp-rs.pl --bim=AA.bim --conversion-file=HumanOmni1_conversion_rsids.txt
#./snp-convert-kgp-rs.pl --bim=AA.bim --conversion-file=HumanOmni1_conversion_rsids.txt --quiet
#-------------------------------------------------------------------------
#
# todo:
# ensure blank entries in conversion files don't get written to bim file
#
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

my $bim;              # original bim file
my $conversion_file;  # file containing kgp/GA conversions
my $quiet;
my $help;

GetOptions('bim=s'             => \$bim,
		   'conversion-file=s' => \$conversion_file,
		   'quiet'             => \$quiet,
		   'help'              => \$help,
	);

# mechanisms for printing help information:
pod2usage(-exitval => 1, -verbose => 2, -output => \*STDOUT)  if ($help);

$bim =~ m/(.+)(\..+$)/;
my $bim_root = $1;
my $bim_suffix = $2;
my $new_bim = sprintf("%s_nokgp%s", $bim_root, $bim_suffix);

open(BIM, "< $bim");
open(NEWBIM, "> $new_bim");
open(KGP, "< $conversion_file");

unless($quiet){
	print sprintf("input file:   %s\n", $bim);
	print sprintf("output file:  %s\n", $new_bim);
}

my $kgp_count = 0;
my $GA_count = 0;

while(my $bim_line = <BIM>){
	chomp $bim_line;
	my @bim_data = split(' ', $bim_line);

	# normal lines with chr > 0 and rs[0-9]+ entries:
	if ($bim_data[0] > 0 & $bim_data[1] =~ /^rs[0-9]+/) {
		#print sprintf("%s\n", $bim_line);
		unless($quiet){
			print ".";
		}
		print NEWBIM sprintf("%s\n", $bim_line);
	}
	elsif ($bim_data[1] =~ /^kgp[0-9]+/) {
		my $kgp = $bim_data[1];
		unless($quiet){
			print "K";
		}

		# grep for kgp entry in conversion file:
		my $rs_kgp_line = `grep $kgp $conversion_file`;
		my @rs_kgp = split(' ', $rs_kgp_line);
		my $rs = $rs_kgp[1];
		if($rs =~ m/,/) {
			$rs =~ m/(rs[0-9]+),.*/;
			$rs = $1;
		}

		$bim_line =~ s/kgp[0-9]+/$rs/;
		print NEWBIM sprintf("%s\n", $bim_line);
		$kgp_count++;
	}
	elsif ($bim_data[1] =~ /^GA[0-9]+/) {
		my $GA = $bim_data[1];
		unless($quiet){
			print "G";
		}

		# grep for kgp entry in conversion file:
		my $rs_GA_line = `grep $GA $conversion_file`;
		my @rs_GA = split(' ', $rs_GA_line);
		my $rs = $rs_GA[1];
		if($rs =~ m/,/) {
			$rs =~ m/(rs[0-9]+),.*/;
			$rs = $1;
		}

		$bim_line =~ s/GA[0-9]+/$rs/;
		print NEWBIM sprintf("%s\n", $bim_line);
		$GA_count++;
	}

}

unless($quiet){
	print "\n";
	print sprintf("kgp: %i \n GA : %i\n",
				  $kgp_count, $GA_count);
}

close(KGP);
close(NEWBIM);
close(BIM);

=head1 NAME

snp-convert-kgp-rs.pl - Replace bim file kgp and GA with rs entries from specified conversion file.

=head1 SYNOPSIS

S<snp-convert-kgp-rs.pl --bim=I<bim_file> --conversion-file=I<conversion_file>>

=head1 ARGUMENTS

=over 4

=item B<--bim I<bim_file>>

Original bim file containing lines of kgp and GA entries.

=item B<--conversion-file I<conversion_file>>

File containing rs conversions corresponding to kgp and GA entries in bim file.

=back

=head1 OPTIONS

=over 4

=item B<--quiet>

Run without printing anything to the screen.
The default is to run without this option which will show progress by printing
"." for each bim line already with an rs number
"K" for each kgp converted and
"G" for each GA converted.

=back


=head1 EXAMPLE

To convert kgp and GA entries in file F<AA.bim> using conversion file
F<HumanOmni1_conversion_rsids.txt>

S<snp-convert-kgp-rs.pl --bim=AA.bim --conversion-file=HumanOmni1_conversion_rsids.txt>


=head1 AUTHOR

 Richard Duncan, richard.duncan@emory.edu
 Emory University, School of Medicine
 Department of Human Genetics

=cut  

