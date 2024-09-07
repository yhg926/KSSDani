
use warnings;
use diagnostics;
use Digest::MurmurHash3 qw( murmur32 );

if(@ARGV < 2){
	die "*.pl <seq1.fa> <seq2.fa> ...";
}

$HALFK = 9 ;
$HALFTL = $HALFK + 1 ;
$K = $HALFK * 2;
$TL = $HALFTL *2 ;

$/ = '>';
for ($n=0 ; $n<@ARGV;$n++) {
#	$hash[$n]->{'filename'} = $ARGV[$n];

	open $f, $ARGV[$n] || die "can't open $ARGV[$n]:$! ";
	<$f>;


	while($seq=<$f>){
		chomp $seq;
		$seq =~ s/\n|\r//g; 
		next if length $seq < $TL ;

		for($i = 0; $i< (length $seq) - $TL +1 ; $i++){
			$tuple = substr($seq,$i,$TL);
			$crkmer = $kmer = substr($tuple,1,$K);
			$crkmer =~ tr/ACGTacgt/TGCATGCA/ ; 
			$crkmer = reverse $crkmer ;
	
			if ($kmer lt $crkmer) {
				$unikmer = $kmer;
				$obj3p = substr($tuple,$TL - 1 ,1);
				$obj5p  = substr($tuple,0,1);
			}
			elsif ($kmer gt $crkmer) {
				$unikmer = $crkmer;
				$obj3p = substr($tuple,0,1);
				$obj3p =~ tr /ACGTacgt/TGCATGCA/ ;
				$obj5p = substr($tuple,$TL - 1, 1);
				$obj5p =~ tr /ACGTacgt/TGCATGCA/ ; 
			}
			else { next;
			}
			next if murmur32($unikmer) % 16 != 1; 
			
			if(exists $hash[$n]->{$unikmer}) {
				if ($hash[$n]->{$unikmer} eq  $obj3p.$obj5p){
					next;
				}
				else {
					$hash[$n]->{$unikmer} = 0 ;
				}
			}
			else{
				$hash[$n]->{$unikmer} = $obj3p.$obj5p; 		
			}
		}
	
	}
 	close $f;
}

for ($n = 1; $n <@ARGV ; $n++){
	$num_n = 0;
	foreach	$ele (keys %{$hash[$n]}){
		 $num_n++ if $hash[$n]->{$ele} ne 0 ;
	}

	for ($j = 0; $j < $n ; $j++){
		$num_j = 0 ;
		$num_ctx = 0;
		$diff_obj = 0;
	
		foreach $ele (keys %{$hash[$j]}){
			next if $hash[$j]->{$ele} eq 0;
			$num_j++;

			if( exists $hash[$n]->{$ele}   ){
				$num_ctx++; 
			
				if ($hash[$n]->{$ele} ne $hash[$j]->{$ele} ){
					$diff_obj++;
				}
			}
		}
		print $ARGV[$n],"\t", $ARGV[$j],"\t",$num_n,"\t",$num_j,"\t",$num_ctx,"\t",$diff_obj,"\t", $diff_obj / $num_ctx, "\t", 1 - $diff_obj / $num_ctx, "\t", $num_ctx/$num_n,"\t",  $num_ctx/$num_j,"\n" ; 
	
	}
}




#my $string = "Hello, World!";
#my $hash = murmur32($string);

#print "MurmurHash3 (x86_32) hash: $hash\n";

