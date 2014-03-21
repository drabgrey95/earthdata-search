ns = @edsc.map

# Meta-layer for managing granule visualizations
ns.GranuleVisualizationsLayer = do (L, dateUtil=@edsc.util.date, GranuleLayer=ns.L.GranuleLayer) ->
  #MIN_PAGE_SIZE = 100

  class GranuleVisualizationsLayer
    constructor: ->
      @_datasetIdsToLayers = {}

    onAdd: (map) ->
      @_map = map
      map.on 'edsc.visibledatasetschange', @_onVisibleDatasetsChange

    onRemove: (map) ->
      @_map = map
      map.off 'edsc.visibledatasetschange', @_onVisibleDatasetsChange

    _onVisibleDatasetsChange: (e) =>
      @setVisibleDatasets(e.datasets)

    setVisibleDatasets: (datasets) =>
      map = @_map

      datasetIdsToLayers = @_datasetIdsToLayers
      newDatasetIdsToLayers = {}

      baseZ = 6
      overlayZ = 16

      for dataset in datasets
        id = dataset.id()
        gibsParams = dataset.gibs()
        if gibsParams?.format == 'jpeg'
          z = Math.min(baseZ++, 9)
        else
          z = Math.min(overlayZ++, 19)

        if datasetIdsToLayers[id]?
          layer = datasetIdsToLayers[id]
        else
          # Note: our algorithms rely on sort order being [-start_date]
          layer = new GranuleLayer(dataset, gibsParams)
          map.addLayer(layer)

        layer.setZIndex(z)
        newDatasetIdsToLayers[id] = layer

      for own id, layer of datasetIdsToLayers
        unless newDatasetIdsToLayers[id]?
          map.removeLayer(layer)

      @_datasetIdsToLayers = newDatasetIdsToLayers

      null

  exports = GranuleVisualizationsLayer