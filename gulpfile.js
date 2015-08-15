var gulp = require('gulp');
var sass = require('gulp-sass');
var livereload = require('gulp-livereload');

gulp.task('sass', function() {
    gulp.src('./sass/style.scss')
        .pipe(sass().on('error', sass.logError))
        .pipe(gulp.dest('./public/css'))
        .pipe(livereload());
});

gulp.task('watch', function () {
    livereload.listen();
    gulp.watch(['./sass/**/*.scss']);
});

gulp.task('default', ['sass', 'watch']);
