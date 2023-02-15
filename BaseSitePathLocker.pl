package MT::Plugin::BaseSitePathLocker;
use MT;
use MT::CMS::Common;
use base qw( MT::Plugin );
use feature qw( state );
use strict;

our $MYNAME = 'BaseSitePathLocker';
our $VERSION = '0.0.1';

my $plugin = __PACKAGE__->new({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Masatoshi TSUCHIYA',
    author_link => 'https://github.com/tsuchm',
    doc_link => 'https://github.com/tsuchm/BaseSitePathLocker',
    description => 'This plugin provides site-specific BaseSitePath.'
});
MT->add_plugin( $plugin );

sub init_registry {
    state $initialized = 0;
    unless( $initialized ){
	$initialized = 1;
	no warnings;
	*_save = \&MT::CMS::Common::save;
	*MT::CMS::Common::save = \&_wrapper_save;
    }
}

sub _wrapper_save {
    my $app = shift;
    my $type = $app->param('_type');
    my $id = $app->param('id') || $app->param('blog_id');
    my $author = $app->user;
    if( $id and ( $type eq 'blog' or $type eq 'website' ) and ( !$author or !$author->is_superuser ) ){
	my $cache = $app->config('BaseSitePath');
	my $class = $app->model($type);
	my $blog = $class->load($id);
	if( $blog->parent_id ){
	    $blog = $class->load( $blog->parent_id );
	}
	printf STDERR "$MYNAME: BaseSitePath is restricted to %s (blog_id=%s)\n", $blog->site_path, $blog->id;
	$app->config( 'BaseSitePath', $blog->site_path );
	my $value = &_save( $app, @_ );
	printf STDERR "$MYNAME: BaseSitePath is restored to %s\n", $cache || '(NULL)';
	$app->config( 'BaseSitePath', $cache );
	$value;
    } else {
	&_save( $app, @_ );
    }
}

1;
