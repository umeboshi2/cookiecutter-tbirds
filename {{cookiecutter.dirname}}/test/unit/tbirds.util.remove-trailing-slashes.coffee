import assert from 'assert'
import removeTrailingSlashes from 'tbirds/util/remove-trailing-slashes'

describe "removeTrailingSlashes", ->
  
  # main test
  testVal = 'foobar/'
  expectedVal = 'foobar'
  for testVal in ['foobar', 'foobar/', 'foobar//', 'foobar////']
    describe "removeTrailingSlashes(\"#{testVal}\")", ->
      it "should return #{expectedVal}", ->
        assert.equal removeTrailingSlashes(testVal), expectedVal

  # test intermediate slashes
  testVal = "/path/to/file"
  expectedVal = "/path/to/file"
  for testVal in ['/path/to/file', '/path/to/file/', '/path/to/file//']
    describe "removeTrailingSlashes(\"#{testVal}\")", ->
      it "should return #{expectedVal}", ->
        assert.equal removeTrailingSlashes(testVal), expectedVal

  # test only slashes
  testVal = "//"
  expectedVal = ''
  describe "removeTrailingSlashes(\"#{testVal}\")", ->
    it "should return \"#{expectedVal}\"", ->
      assert.equal removeTrailingSlashes(testVal), expectedVal

