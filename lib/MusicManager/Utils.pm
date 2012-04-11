package MusicManager::Utils;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = qw(mm_sort_smart);

# Utility Functions
sub mm_sort_smart($$) {
    my ($a,$b) = @_;
    # Lowercase
    my $A = lc $a;
    my $B = lc $b;

    # Strip "the"
    $A =~ s/^the\s+//;
    $B =~ s/^the\s+//;

    # Compare
    return $A cmp $B;
}
