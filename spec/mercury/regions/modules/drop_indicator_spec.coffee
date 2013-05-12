#= require spec_helper
#= require mercury/core/region
#= require mercury/regions/modules/drop_indicator

describe "Mercury.Region.Modules.DropIndicator", ->

  Klass = null
  Module = Mercury.Region.Modules.DropIndicator
  subject = null

  beforeEach ->
    class Klass extends Mercury.Region
      @include Module
    subject = new Klass('<div id="foo">')

  describe "#included", ->

    it "sets up the indicator element", ->
      expect( subject.$dropIndicator.is('.mercury-region-drop-indicator') ).to.be.true


  describe "#buildDropIndicator (via the build event)", ->

    it "appends the indicator after @el", ->
      spyOn(subject.$el, 'after')
      subject.trigger('build')
      expect( subject.$el.after ).calledWith(subject.$dropIndicator)

    it "calls #delegateEvents", ->
      spyOn(subject, 'delegateEvents')
      subject.trigger('build')
      expect( subject.delegateEvents ).calledWith
        dragenter: 'showDropIndicator'
        dragover: 'showDropIndicator'
        dragleave: 'hideDropIndicator'
        drop: 'hideDropIndicator'


  describe "#releaseDropIndicator (via the release event)", ->

    it "removes the indicator from the dom", ->
      spyOn(subject.$dropIndicator, 'remove')
      subject.trigger('release')
      expect( subject.$dropIndicator.remove ).called


  describe "#dropIndicatorPosition", ->

    it "returns css attributes to position the indicator", ->
      spyOn(subject.$el, 'position', -> top: 10, left: 20)
      spyOn(subject.$el, 'outerHeight', -> 100)
      spyOn(subject.$el, 'outerWidth', -> 100)
      expect( subject.dropIndicatorPosition() ).to.eql(top: 60, left: 70, display: 'block')


  describe "#showDropIndicator (via dragenter/dragover)", ->

    it "clears the timeout", ->
      subject.dropIndicatorTimer = '_timer_'
      spyOn(window, 'clearTimeout')
      subject.$el.trigger('dragenter')
      expect( clearTimeout ).calledWith('_timer_')

    it "tracks that it's visible", ->
      subject.dropIndicatorVisible = false
      subject.$el.trigger('dragover')
      expect( subject.dropIndicatorVisible ).to.be.true

    it "positions the indicator", ->
      spyOn(subject, 'dropIndicatorPosition', -> '_css_')
      spyOn(subject.$dropIndicator, 'css')
      subject.$el.trigger('dragover')
      expect( subject.$dropIndicator.css ).calledWith('_css_')

    it "delays setting the opacity", ->
      spyOn(subject, 'delay').yieldsOn(subject)
      subject.$el.trigger('dragenter')
      expect( subject.delay ).calledWith(50, sinon.match.func)
      expect( subject.$dropIndicator.css('opacity') ).to.eq('1')

    it "does nothing if we're previewing", ->
      subject.previewing = true
      spyOn(window, 'clearTimeout')
      subject.$el.trigger('dragenter')
      expect( clearTimeout ).not.called

    it "does nothing if it's already visible", ->
      subject.dropIndicatorVisible = true
      spyOn(window, 'clearTimeout')
      subject.$el.trigger('dragover')
      expect( clearTimeout ).not.called


  describe "#hideDropIndicator (via dragleave/drop)", ->

    it "sets the opacity to 0", ->
      subject.$dropIndicator.css(opacity: 1)
      subject.$el.trigger('dragleave')
      expect( subject.$dropIndicator.css('opacity') ).to.eq('0')

    it "tracks that it's not visible", ->
      subject.dropIndicatorVisible = true
      subject.$el.trigger('dragleave')
      expect( subject.dropIndicatorVisible ).to.be.false

    it "sets a timer to fully hide the indicator", ->
      spyOn(subject, 'delay').yieldsOn(subject)
      spyOn(subject.$dropIndicator, 'hide')
      subject.$el.trigger('drop')
      expect( subject.delay ).calledWith(500, sinon.match.func)
      expect( subject.$dropIndicator.hide ).called