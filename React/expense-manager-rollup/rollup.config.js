import babel from '@rollup/plugin-babel';
import resolve from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import replace from '@rollup/plugin-replace';
import serve from 'rollup-plugin-serve';
import livereload from 'rollup-plugin-livereload';

export default {
   input: 'src/index.js',
   output: {
      file: 'public/index.js',
      format: 'iife',
   },
   plugins: [
      commonjs({
         include: [
            'node_modules/**',
         ],
         exclude: [
            'node_modules/process-es6/**',
         ],
      }),
      resolve(),
      babel({
         exclude: 'node_modules/**'
      }),
      replace({
         'process.env.NODE_ENV': JSON.stringify('production'),
      }),
      livereload('public'),
      serve({
         contentBase: 'public',
         port: 3000,
         open: true,
      }), // index.html should be in root of project
   ]
}