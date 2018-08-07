#!/usr/bin/env perl
use 5.018;
use Encode;
my $fname = $ARGV[0];
my $BLOCK_SIZE = 0x2**24;
my $dir_ent = 0x20;
my $cnt = 0;
my $dir_sec = 15;
open(F,"<$fname") or die("Unable to open file $fname, $!");
binmode(F); read(F, my $buf,$BLOCK_SIZE);
my @buf = unpack "C*", $buf;

my $byte_sec = lit(@buf[11 .. 12]);
my $sec_clst = $buf[13];
my $Reserved = lit(@buf[14 .. 15]);
my $hid_sec = lit(@buf[28 .. 31]);
my $tol_sec = lit(@buf[32 .. 35]);
my $fat_size = lit(@buf[36 .. 39]);
my $root_dir = lit(@buf[44 .. 47]);
=eod
say "byte per sector : ".hex($byte_sec);
say "sector per cluster : ".hex($sec_clst);
say "Reserved Sector Count : ".hex($Reserved);
say "hidden sector : ".hex($hid_sec);
say "total sector : ".hex($tol_sec);
say "fat_size : ".hex($fat_size);
say "root dir cluster : ".hex($root_dir);
=cut
my $fat2 = hex($Reserved) + hex($fat_size) * hex($root_dir);


$cnt += ($fat2*512);
$cnt += 32;

while($buf[$cnt]){
	my ($flag,$name);
	if($buf[$cnt+11] == 0x0f && $buf[$cnt] != 0xE5){$name = lfn(@buf[$cnt..$cnt+31]);
		while(1){
		if($buf[$cnt+32] < 0x10 || $buf[$cnt] == 0x0f){
			$cnt += 32; $dir_sec--; my $tname = lfn(@buf[$cnt .. $cnt+31]);
			$name = $tname.$name;
		}
		else{last;}
	}
	}
	elsif($buf[$cnt] != 0xE5) {
		$name = sfn(@buf[$cnt..$cnt+31]);
	}
	if($name) {
		print "name : $name ";
		my $size = filesize(@buf[$cnt+28 .. $cnt+31]);
		unless(hex($size)){print " // Directory\n";}
		else{printf("size : %d bytes\n",hex($size))};
	}
	$dir_sec--;
	$cnt += 32;
}
sub filesize(){
	my $size = sprintf("%02x%02x%02x%02x",$_[-1],$_[-2],$_[-3],$_[-4]);
#unless ($size) { $size = "Directory";}
	return $size;
}
sub sfn(){
	my @name = @_[0 .. 10];
	my $ret;
	foreach(@name){
		if($_ != 0x20){ $ret .= chr($_);}
	}
	return $ret;
}
sub lfn(){
	my @tmp;
	my $ret;
	my $flag = 0;
# Name1
	$tmp[0] = sprintf("%02x%02x",$_[1],$_[2]);
	$tmp[1] = sprintf("%02x%02x",$_[3],$_[4]);
	$tmp[2] = sprintf("%02x%02x",$_[5],$_[6]);
	$tmp[3] = sprintf("%02x%02x",$_[7],$_[8]);
	$tmp[4] = sprintf("%02x%02x",$_[9],$_[10]);
# Name2
	$tmp[5] = sprintf("%02x%02x",$_[14],$_[15]);
	$tmp[6] = sprintf("%02x%02x",$_[16],$_[17]);
	$tmp[7] = sprintf("%02x%02x",$_[18],$_[19]);
	$tmp[8] = sprintf("%02x%02x",$_[20],$_[21]);
	$tmp[9] = sprintf("%02x%02x",$_[22],$_[23]);
	$tmp[10] = sprintf("%02x%02x",$_[24],$_[25]);
# Name3
	$tmp[11] = sprintf("%02x%02x",$_[28],$_[29]);
	$tmp[12] = sprintf("%02x%02x",$_[30],$_[31]);
	$ret = enc16(@tmp);	
	return $ret;
}	
sub enc16(){
	my ($tmp,$ret,$flag);
	foreach(@_){
		unless($flag){
			if($_ == 0x00){$flag = 1;}
			$tmp .= chr(hex($_));
		}
	}
	$ret = encode('utf-16LE',$tmp);
	return $ret;
}

sub lit(){
	my $cnt = $#_ +1;
	my $ret = "";
	while($cnt){
		$ret .= sprintf("%02x",$_[$cnt-1]);
		$cnt --;
	}
	return $ret;
}

