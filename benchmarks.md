# Benchmarks

## Commit: 65e6aa24294f79e8a335af93e247d35878a85869

### ImageMagick

```bash
> time npm test

> deepzoomtools@0.0.1 test /Users/dgasienica/workspace/node-deepzoomtools
> node_modules/.bin/_coffee test


real  1m48.201s
user  1m33.515s
sys 0m13.699s
```

### VIPS

```bash
> time vips dzsave images/1.jpg images/1-vips --overlap=1 --tile-width=254 --tile-height=254 --suffix=.jpg

real  0m1.651s
user  0m1.573s
sys 0m1.643s
```
