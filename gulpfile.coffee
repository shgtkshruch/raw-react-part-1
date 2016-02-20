'use strict'

gulp = require 'gulp'
$ = require('gulp-load-plugins')()
browserSync = require 'browser-sync'
autoprefixer = require 'autoprefixer'
sorting = require 'postcss-sorting'
mqpacker = require 'css-mqpacker'
fmt = require 'cssfmt'
del = require 'del'
ghpages = require 'gh-pages'
path = require 'path'

config =
  src: 'src'
  dest: 'dist'

gulp.task 'browser-sync', ->
  browserSync
    watchOptions:
      debounceDelay: 0
    server:
      baseDir: config.dest
      routes:
        '/bower_components': 'bower_components'
    notify: false
    reloadDelay: 0
    browser: 'Google Chrome Canary'

gulp.task 'html', ['jade'], ->
  gulp.src config.dest + '/index.html'
    .pipe $.useref()
    .pipe gulp.dest config.dest

gulp.task 'jade', ->
  gulp.src config.src + '/**/*.jade'
    .pipe $.plumber()
    .pipe $.changed config.dest,
      extension: '.html'
    .pipe $.jade
      pretty: true
    .pipe $.prettify
      condense: true
      padcomments: false
      indent: 2
      indent_char: ' '
      indent_inner_html: 'false'
      brace_style: 'expand'
      wrap_line_length: 0
      preserve_newlines: true
    .pipe gulp.dest config.dest
    .pipe browserSync.reload
      stream: true

gulp.task 'sass', ->
  gulp.src config.src + '/styles/style.scss'
    .pipe $.sass().on 'error', $.sass.logError
    .pipe $.postcss [
      autoprefixer
        browsers: ['last 2 version', 'ie 9', 'ie 8']
      sorting
        'sort-order': 'yandex'
      mqpacker
      fmt
    ]
    .pipe gulp.dest config.dest + '/styles'
    .pipe browserSync.reload
      stream: true

gulp.task 'javascript', ->
  gulp.src config.src + '/scripts/*.js'
    .pipe $.plumber()
    .pipe $.changed config.dest,
      extension: '.js'
    .pipe gulp.dest config.dest + '/scripts'
    .pipe browserSync.reload
      stream: true

gulp.task 'image', ->
  gulp.src config.src + '/images/*'
    .pipe $.imagemin
      progressive: true
      interlaced: true
    .pipe gulp.dest config.dest + '/images'

gulp.task 'clean', ->
  del ['dist/partials', 'dist/scripts/*.js', '!dist/scripts/{main,vendor}.js']

gulp.task 'publish', ->
  ghpages.publish path.join __dirname, config.dest

gulp.task 'default', ['jade', 'sass', 'javascript', 'image', 'browser-sync'], ->
  gulp.watch config.src + '/**/*.jade', ['jade']
  gulp.watch config.src + '/styles/*.scss', ['sass']
  gulp.watch config.src + '/scripts/*.js', ['javascript']
  gulp.watch config.src + '/images/*', ['image']

gulp.task 'prebuild', ['html', 'sass', 'javascript', 'image']

gulp.task 'build', ['prebuild'], ->
  gulp.start 'clean'
