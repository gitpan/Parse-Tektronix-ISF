package Parse::Tektronix::ISF;

use warnings;
use strict;

use Exporter;

our @ISA = qw(Exporter);

=head1 NAME

Parse::Tektronix::ISF - Parse the ISF file generated by certain models of
Tektronix oscillascope (TDS 3000, DPO 4000, etc)

=head1 VERSION

Version 0.0102

=cut

our $VERSION = '0.0103';


=head1 SYNOPSIS

    use Parse::Tektronix::ISF;

    my $foo = Parse::Tektronix::ISF::Read('filename.isf');
    print $foo->{NR_PT}; # get number of data points
    print $foo->{DATA}[100][1]; # get y coordinate of the 101st data point

=cut


our %EXPORT_TAGS = ( 'all' => [ qw(
        Read
        ConvertToCSV
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);


=head1 EXPORT

None by default.

All functions can be exported by 

    use Parse::Tektronix::ISF ':all';

=head1 FUNCTIONS

=head2 Read

Takes one parameter as the name of the .isf file.

Read data from file into a hash reference which contains all the
information in the header.  For example, to get the number of data
points in a file:

    my $foo = Parse::Tektronix::ISF::Read('filename.isf');
    print 'The file contains ', $foo->{NR_PT}, " points\n";
    print 'x, y units : ', $foo->{XUNIT}, ',', $foo->{YUNIT}, "\n";
    print 'info : ', $foo->{WFID}, "\n";

In addition, the raw data are stored in the key 'DATA' as an array
reference, each element is a data point which is stored as an array
reference of (x, y) values.  For example, to get the x, y value of the
1000th point:

    my $foo = Parse::Tektronix::ISF::Read('filename.isf');
    my ($x, $y) = @{$foo->{DATA}[999]};

=cut

sub Read {
    my ($fn) = @_;

    my $size = -s $fn;
    my $header;
    my $fileopen = 1;
    open F, $fn or return undef;
    binmode F;
    read F, $header, 269;
    $header =~ s/:WFMPRE://;
    $header =~ s/:CURVE//;
    my $h;
    %$h = ($header =~ /(\S+)\s+(.+?);/g);

    my $datablock;
    read F, $datablock, 2*$h->{NR_PT};
    my @iy = unpack 'v*', $datablock;
    $h->{DATA} = [map {
        [$h->{XZERO} + $h->{XINCR}*$_,
         $h->{YMULT}*($iy[$_] - $h->{YOFF})]
    } 0..$#iy];
    close F;

    return $h;
    
}

=head2 ConvertToCSV

Takes two parameters, they are the input/output file names.

Converts a .isf file to a .csv file. 

=cut

sub ConvertToCSV {
    my ($in, $out) = @_;
    unless ($out) {
        $out = $in;
        $out =~ s/isf$/csv/i;
    }
    my $h = Read($in);
    open F, ">$out" or return undef;
    for my $l (@{$h->{DATA}}) {
        print F join(',', @{$l}),"\n";
    }
    close F;
    1;
}

=head1 SEE ALSO

This module was inspired by the MATLAB program from John Lipp :
http://www.mathworks.com/matlabcentral/fileexchange/6247

Tektronics provided isf to csv conversion program (.exe) at
http://www2.tek.com/cmswpt/swdetails.lotr?ct=SW&cs=sut&ci=5355&lc=EN

=head1 AUTHOR

Ruizhe Yang, C<< <razor at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-parse-tektronix-isf at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Parse-Tektronix-ISF>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Parse::Tektronix::ISF


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Parse-Tektronix-ISF>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Parse-Tektronix-ISF>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Parse-Tektronix-ISF>

=item * Search CPAN

L<http://search.cpan.org/dist/Parse-Tektronix-ISF/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Ruizhe Yang, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Parse::Tektronix::ISF
