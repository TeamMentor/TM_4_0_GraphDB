// this is not working due to https://github.com/wallabyjs/public/issues/227

module.exports = function (wallaby) {
  process.env.NODE_PATH = require('path').join(wallaby.localProjectDir, 'node_modules');
  process.env.localProjectDir = wallaby.localProjectDir

  console.log('[in Wallaby-Node for TM_GraphDB] ');

  return {
    files: [ 'src/**/*.coffee'],

    tests: ['test/**/*.coffee'],

    env: {
      type  : 'node',
      runner: 'node'
    },
    workers: {
      initial: 1,
      regular: 1
    }
  };
};
