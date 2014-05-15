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
#./snp-convert-kgp-rs.pl --bfile AA --conversion-file HumanOmni1_conversion_rsids.txt --output updated_data
#-------------------------------------------------------------------------
#
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

my $bfile;              # plink binary file input
my $conversion_file;    # file containing kgp/GA conversions
my $remove_chr0;        # remove chr0 entries
my $output_file;        # output filename used by plink
my $quiet;
my $help;

GetOptions('bfile=s'           => \$bfile,
           'conversion-file=s' => \$conversion_file,
           'output=s'          => \$output_file,
           'quiet'             => \$quiet,
           'help'              => \$help,
    );

# mechanisms for printing help information:
pod2usage(-exitval => 1, -verbose => 2, -output => \*STDOUT)  if ($help);

#============================================================
# first copy conversion file and remove duplicate rs values:
#============================================================
unless($quiet){
    print "making copy of conversion file and removing duplicate rs entries....";
}
my $conversion_file_mod = $conversion_file;
$conversion_file_mod =~ s/\./_mod\./;
system "cp $conversion_file $conversion_file_mod";

my $sed_opts = "-i -r";
if($quiet){
    $sed_opts = sprintf("%s --quiet", $sed_opts);
}
system("sed -i -r 's/,[a-zA-Z]+[0-9]+//g' $conversion_file_mod");

unless($quiet){
    print "done\n";
}

#============================================================
# let plink do everything else:
#============================================================
my $plink_exe = `which plink`; chomp $plink_exe;
my $plink_opts = sprintf("--noweb --bfile %s --update-map %s --update-name --make-bed --out %s",
    $bfile, $conversion_file_mod, $output_file);
if($quiet){
    $plink_opts = sprintf("%s --silent", $plink_opts);
}

my $cmd = sprintf("$plink_exe $plink_opts");
print $cmd . "\n";
system $cmd;

=head1 NAME

snp-convert-kgp-rs.pl - strip duplicate conversions, then run plink to remap data

=head1 SYNOPSIS

S<snp-convert-kgp-rs.pl --bfile I<BFILE> --conversion-file I<CONVERSION_FILE> --output I<OUTPUT_FILE>>

=head1 ARGUMENTS

=over 4

=item B<--bfile I<BFILE>>

Original binary fileroot for plink input, containing lines of kgp and GA entries for conversion

=item B<--conversion-file I<CONVERSION_FILE>>

File containing rs conversions corresponding to kgp and GA entries in bim file.

=item B<--output I<OUTPUT_FILE>>

File containing rs conversions corresponding to kgp and GA entries in bim file.

=back

=head1 OPTIONS

=over 4

=item B<--quiet>

Run without printing anything to the screen.

=item B<--help>

Print this help screen then exit.

=back


=head1 EXAMPLE

To convert kgp and GA entries in files F<AA.{bed,bim,fam}> using conversion file
F<conversion_rsids.txt> and process the results into files F<AA_converted.{bed,bim,fam}>:

S<snp-convert-kgp-rs.pl --bfile AA --conversion-file conversion_rsids.txt --output AA_converted>


=head1 AUTHOR

 Richard Duncan, richard.duncan@emory.edu
 Emory University, School of Medicine
 Department of Human Genetics

=cut  

