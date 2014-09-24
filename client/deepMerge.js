'use strict';

module.exports = function deepMerge(src, tgt) {
    if (tgt === undefined) {
        tgt = {};
    }

    for (var attrname in src) {
        var v = src[attrname];
        if (typeof v == "object" &&
            tgt.hasOwnProperty(attrname) &&
            (typeof(tgt[attrname])) == "object") {

            deepMerge(v, tgt[attrname]);
        } else {
            tgt[attrname] = v;
        }
    }

    return tgt;
};
