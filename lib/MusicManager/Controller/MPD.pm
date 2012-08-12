package MusicManager::Controller::MPD;
use Mojo::Base 'Mojolicious::Controller';
use Try::Tiny;

my %_mpd_can_do = map { $_ => 1 } qw(play pause stop prev next);
my %_mpd_can_toggle = map { $_ => 1 } qw(random repeat);

# Handle Volume Controls
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
    }

    my $volume = $self->app->mpd->status->volume;

    $self->render( json => { current_volume => $volume} );
}

# Handle MPD Control Objects
sub do {
    my $self = shift;
    my $name = $self->stash( 'command' );

    my %status = ( command => $name );
    if( exists $_mpd_can_do{$name} ) {
        $status{attempted} = 1;
        my $err=undef;
        try {
            no strict;
            $self->app->mpd->$name();
            $status{success} = 1;
        } catch {
            $status{error} = shift;
        };
    }
    else {
        $status{error} = "Invalid command sent";
    }

    $self->render( json => \%status );
}

# Handle Toggles
sub toggle {
    my $self = shift;
    my $name = $self->stash( 'setting' );

    my %status = ( setting => $name );
    if( exists $_mpd_can_toggle{$name} ) {
        my $err=undef;
        $status{attempted} = 1;
        try {
            no strict;
            my $new = !$self->app->mpd->status->$name;
            $self->app->mpd->$name($new);
            $status{success} = 1;
            $status{value} = $new;
        } catch {
            $status{error} = shift;
        };
    }
    else {
        $status{error} = "Invalid setting toggle attempted.";
    }

    $self->render(json => \%status );
}

# Handle Track changing
sub playid {
    my $self = shift;
    my $id = $self->stash( 'song_id' );

    my %status = ( song => $id );
    if( $id =~ /^[0-9]+$/ ) {
        my $err=undef;
        $status{attempted} = 1;
        try {
            $self->app->mpd->playid($id);
            $status{success} = 1;
        } catch {
            $status{error} = shift;
        };
    }
    else {
        $status{error} = "Invalid song id";
    }

    $self->render( json => \%status );
}

# Return True
1;
