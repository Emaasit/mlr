context("regr_rknn")

test_that("regr_rknn", {
  requirePackages("rknn", default.method = "load")
  
  k = c(2L, 4L)
  r = c(200L, 600L)
  mtry = c(2L, 3L)
  parset.grid = expand.grid(k= k, r = r, mtry = mtry)
  parset.list = apply(parset.grid, MARGIN = 1L, as.list)
  #rknn needs integer seed for reproducibility
  parset.list = lapply(parset.list, function(x) c(x, seed = 2015L))
  
  old.predicts.list = list()
  
  for (i in 1L:length(parset.list)) {
    parset = parset.list[[i]]
    train = regr.num.train
    target = train[, regr.num.target]
    train[, regr.num.target] = NULL
    test = regr.num.test
    test[, regr.num.target] = NULL
    pars = list(data = train, y = target, newdata = test)
    pars = c(pars, parset)
    p = do.call(rknn::rknnReg, pars)$pred
    old.predicts.list[[i]] = p
  }
  
  testSimpleParsets("regr.rknn", regr.num.df, regr.num.target, regr.num.train.inds,
                    old.predicts.list, parset.list)
  
  tt = function (formula, data, k = 1L, r = 500L, mtry = 2L, seed = 2015L, cluster = NULL) {
    return(list(formula = formula, data = data, k = k, r = r, mtry = mtry,
                seed = seed, cluster = cluster))
  }
  
  tp = function(model, newdata) {
    target = as.character(model$formula)[2L]
    train = model$data
    y = train[, target]
    train[, target] = NULL
    newdata[, target] = NULL
    rknn::rknnReg(data = train, y = y, newdata = newdata, k = model$k, r = model$r,
                  mtry = model$mtry,  seed = model$seed, cluster = model$cluster)$pred
  }
  testCVParsets(t.name = "regr.rknn", df =  regr.num.df,
                target = regr.num.target, tune.train = tt, tune.predict = tp,
                parset.list = parset.list) 
})