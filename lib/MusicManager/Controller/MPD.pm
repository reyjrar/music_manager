package MusicManager::Controller::MPD;
use Mojo::Base 'Mojolicious::Controller';
use Try::Tiny;

my %_mpd_can_do = map { $_ => 1 } qw(play pause stop prev next);


sub volume {
    my $self = shift;
    my %values = (
        up      => '+5',
        down    => '-5',
        mute     => 0,
    );

    my $mv = $self->stash( 'adjustment' );

    if( exists $values{$mv} ) {
        $self->app->mpd->volume( $values{$mv} );
        $self->flash( "Volume adjusted $mv" );
    }
    else {
        $self->flash(error => "Unknown Volume Adjustment '$mv'" );
    }

    $self->redirect_to('/');
}

# Handle MPD Control Objects
sub do {
    my $self = shift;
    my $name = $self->stash( 'command' );

    if( exists $_mpd_can_do{$name} ) {
        my $err=undef;
        try {
            no strict;
            $self->app->mpd->$name();
        } catch {
            $err = shift;
        };
        $err ? $self->flash(error => "MPD Encountered Error Attempting: $name" )
             : $self->flash(message => "MPD Server executed : $name");
    }
    else {
        $self->flash(error => "Unknown MPD Action: $name");
    }

    $self->redirect_to('/');
}

1;
