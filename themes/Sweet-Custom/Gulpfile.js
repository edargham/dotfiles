var gulp = require('gulp');
var sass = require('gulp-sass')(require('sass'));
var exec = require('gulp-exec');

// Optimized SASS options for faster compilation
var sassOptions = {
    outputStyle: 'expanded',
    sourceComments: false,
    quietDeps: true,
    silenceDeprecations: ['legacy-js-api', 'import', 'color-functions', 'global-builtin', 'strict-unary', 'slash-div', 'mixed-decls']
};

gulp.task('styles', function(done) {
    // Only compile main entry files, not all SCSS files
    gulp.src(['gtk-3.0/gtk.scss', 'gtk-3.0/gtk-dark.scss'])
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(gulp.dest('./gtk-3.0/'))
        .pipe(exec(' gsettings set org.gnome.desktop.interface gtk-theme "Sweet-Custom"'))
    done();
});

gulp.task('styles4', function(done) {
    // Only compile main entry files
    gulp.src(['gtk-4.0/gtk.scss', 'gtk-4.0/gtk-dark.scss'])
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(gulp.dest('./gtk-4.0/'))
    done();
});

gulp.task('shell-style', function(done) {
    // Only compile main entry files
    gulp.src(['gnome-shell/gnome-shell.scss', 'gnome-shell/earlier-versions/gnome-shell.scss'])
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(gulp.dest('./gnome-shell/'))
        .pipe(exec('gsettings set org.gnome.shell.extensions.user-theme name "Sweet" || true'))
    done();
});

gulp.task('cinnamon-style', function(done) {
    // Only compile main entry files
    gulp.src(['cinnamon/cinnamon.scss', 'cinnamon/cinnamon-dark.scss'])
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(gulp.dest('./cinnamon/'))
    done();
});

// Add a fast build task that compiles everything efficiently
gulp.task('build-fast', gulp.parallel(['styles', 'styles4', 'cinnamon-style', 'shell-style']));

// Add a quick GTK-only build for theme testing
gulp.task('gtk-only', gulp.parallel(['styles', 'styles4']));

//Watch task
gulp.task('default',function() {
    gulp.watch('gtk-3.0/**/*.scss', gulp.series('styles'));
});

gulp.task('shell',function() {
    gulp.watch('gnome-shell/**/*.scss', gulp.series('shell-style'));
});

gulp.task('cinnamon',function() {
    gulp.watch('cinnamon/**/*.scss', gulp.series('cinnamon-style'));
});