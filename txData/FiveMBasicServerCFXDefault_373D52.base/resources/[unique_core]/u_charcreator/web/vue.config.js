module.exports = {
  publicPath: './',
  outputDir: 'dist',
  filenameHashing: false,
  configureWebpack: {
    optimization: {
      splitChunks: false
    }
  },
  devServer: {
    hot: false,
    liveReload: false
  }
}
