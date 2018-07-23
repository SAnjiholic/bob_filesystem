#!/usr/bin/env perl
use 5.018;

my $fname = $ARGV[0];
my $BLOCK_SIZE =-s $fname;
my $na = 0x1d6;
my $rs = 0x1ca;
my $size = 0x200;
my ($buf, $bp, $pp , $sp, $rp, $cnt, $s_size);
open(F,"<$fname") or die("Unable to open file $fname, $!");
binmode(F); read(F,$buf,$BLOCK_SIZE);
my @buf = unpack "C*", $buf;
my @sec1 = @buf[0x1f6 .. 0x1f9];

$bp = hex(ltob(@sec1));
$pp = $bp * $size;

printf ("EBR Address : %x \n",$bp);
while(1){
	$cnt++;
	$pp = ($bp+$rp) * $size;
	$sp = ($bp+$rp) * $size;
	printf("%d Sector : 0x%x // ", $cnt,$pp);
	$pp += $na; $sp += $rs;
	my @tmp = @buf[$pp.. $pp+3];
	$rp = hex(ltob(@tmp));
	@tmp = @buf[$sp.. $sp+3];
	$s_size = hex(ltob(@tmp));
	printf ("size = 0x%x \n", $s_size);
	last unless ($rp);
}
sub ltob(){
	my $ret = sprintf("%02x%02x%02x%02x",$_[-1],$_[-2],$_[-3],$_[-4]);
}
