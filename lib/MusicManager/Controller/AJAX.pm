package MusicManager::Controller::AJAX;

use Mojo::Base 'Mojolicious::Controller';

sub current_track {
    my $self = shift;

    my %curr = map { $_ => '' } qw(id file title artist album);
    if( my $t = $self->app->mpd->current ) {
        %curr = (
            id => $t->id,
            title => $t->title,
            artist => $t->artist,
            album => $t->album,
            file => $t->file,
        );
    }

    $self->render( json => { "current_track" => \%curr } );
}

1;
