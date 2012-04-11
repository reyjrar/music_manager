package MusicManager::Controller::Library;
use Mojo::Base 'Mojolicious::Controller';
use MusicManager::Utils;

sub artists {
    my $self = shift;
    my @artists = sort mm_sort_smart $self->app->mpd->collection->all_artists;

    $self->stash( artists => \@artists );
    $self->render();
}

sub artist {
    my $self = shift;

    # Grab the artist
    my $artist = $self->stash('artist');

    my @albums = sort mm_sort_smart $self->app->mpd->collection->albums_by_artist( $artist );
    $self->stash( albums => \@albums );

    $self->render();
}

1;
