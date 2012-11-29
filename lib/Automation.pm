package Automation;

use 5.014002;

use Moose;
use State;

has 'states' => (
    is  => 'rw',
    isa => 'ArrayRef[State]',
);

sub read_file {
    my ( $self, $file_path ) = @_;
    open my $in, "<", $file_path or die "cannot open the transition table file";
    my $first_line = <$in>;
    my @symbols = split /\s+/, $first_line;
    shift @symbols;    #remove 'state'

    while (<$in>) {
        my $count = 0;
        my ($state_index) = $_ =~ /(\d+)/;
        my $states = $self->states;
        $states->[$state_index] ||= new State(num=>$state_index);
        while (/{.*?}|#/g) {
            my $entry = $&;
            while ( $entry =~ /\d+/g ) { 
                $states->[$state_index]->add_out_transition($symbols[$count] , $&);
            }
            $count++;
        }

        $self->states($states);
    }
}
sub is_empty       { }
sub is_nfa         { }
sub is_dfa         { }
sub to_dfa         { }
sub min_dfa        { }
sub get_states_num { }

1;
