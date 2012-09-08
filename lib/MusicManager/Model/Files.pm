package MusicManager::Model::Files;
use Mojo::Base -base;
use File::Spec;
use File::Basename;
use File::Find::Rule;

has 'media_dir';

my %_valid_media_exts = map { $_ => 1 } qw(mp3 Mp3 MP3 ogg OGG aac AAC);

sub songs_from_path {
    my ($self,@dirs) = @_;

    my $dir = File::Spec->catdir( $self->media_dir, @dirs );
    my @patterns = map { "*.$_" } keys %_valid_media_exts;

    my $STRIP_MEDIA_DIR = 1 + length $self->media_dir;
    my @files = map { substr $_, $STRIP_MEDIA_DIR }
            File::Find::Rule->file()->name( @patterns )->in( $dir );

    return wantarray ? @files : \@files;
}

sub song_at {
    my ($self,$path) = @_;

    my @path = File::Spec->split_path( $path );
    my @safe = File::Spec->no_upwards( @path );
    my $safe_path = File::Spec->catfile( @safe );

}

sub song_search {
    my ($self,@keywords) = @_;

    # Build search strings
    my @search = ();
    my @files = map { "*.$_" } keys %_valid_media_exts;
    foreach my $token ( @keywords  ) {
        $token =~ s/[^A-Za-z0-9']//g;
        push @search, qr/$token/;
    }

    my $dir = File::Spec->catdir( $self->media_dir );
    my $STRIP_MEDIA_DIR = 1 + length $self->media_dir;

    # Do the search
    my $rule = File::Find::Rule->new();
    my @matches = map { substr $_, $STRIP_MEDIA_DIR } $rule->file()->in( $dir )->or(
        $rule->new->file->and( $rule->new->name( @search ), $rule->new->name(@files) ),
        $rule->new->file->and( $rule->new->directory->name( @search ), $rule->new->name(@files) )
    );

}
