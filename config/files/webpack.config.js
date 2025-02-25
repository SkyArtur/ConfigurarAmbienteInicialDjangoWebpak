const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
require("dotenv").config();

module.exports = {
    mode: "development",
    entry: {
        main: "./src/js/index.js",
        styles: "./src/sass/main.sass"
    },
    output: {
        path: path.resolve(__dirname, `${process.env.APP || "dist"}/static`),
        filename: "js/[name].min.js"
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader",
                    options: {
                        presets: ["@babel/preset-env"]
                    }
                }
            },
            {
                test: /\.sass$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    "css-loader",
                    "sass-loader"
                ]
            },
            {
                test: /\.js$/,
                enforce: "pre",
                use: ["source-map-loader"],
            }
        ]
    },
    devtool: "source-map",
    plugins: [
        new MiniCssExtractPlugin({
            filename: "css/[name].min.css"
        })
    ],
    optimization: {
        minimize: true,
        minimizer: [
            new TerserPlugin({
                test: /\.js(\?.*)?$/i,
            }),
            new CssMinimizerPlugin(),
        ],
    },
    watch: true
};