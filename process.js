const {find, findKey, sortBy, forEach} = require('lodash')
const jsonfile = require('jsonfile')
const moment = require('moment')
const program = require('commander')
const LIBRARY_FILE = './library.json'
const library = require(LIBRARY_FILE)
const ulid = require('ulid')

program
  .version('2.0.0')
  .option('-e, --episode <n>', 'Reprocess Episode', parseInt)
  .parse(process.argv)

if (!program.episode) {
  console.log('No such episode')
  process.exit()
}

const source = require(`./data/episode_${program.episode}.json`)

console.log(`Processing episode #${program.episode}`)

let episodeId = findKey(library.episodes, {'number': source.number})
if (!episodeId) {
  episodeId = ulid()
  library.episodes[episodeId] = {
    number: source.number,
    tracks: []
  }
}
const episode = library.episodes[episodeId]
episode.soundcloudUrl = source['listen_url']
episode.artworkUrl = source['artwork_url']
episode.broadcastedAt = source.date
let newTrackCount = 0
forEach(source.tracks, (track, index) => {
  if (!track.artist && !track.title) {
    return
  }
  let trackId = Object.keys(library.tracks).find((trackId) => {
    let libraryTrack = library.tracks[trackId]
    let conditions = {artist: false, title: false}
    if (libraryTrack.artist && track.artist && libraryTrack.artist.trim().toLowerCase() === track.artist.trim().replace(/['"](.+)['"]/, '$1').toLowerCase()) {
      conditions.artist = true
    }
    if (libraryTrack.title && track.title && libraryTrack.title.trim().toLowerCase() === track.title.trim().replace(/['"](.+)['"]/, '$1').toLowerCase()) {
      conditions.title = true
    }

    if (libraryTrack.title && !libraryTrack.artist) {
      return conditions.title === true
    } else if (libraryTrack.artist && !libraryTrack.title) {
      return conditions.artist === true
    } else {
      return conditions.artist === true && conditions.title === true
    }
  })

  let playlistId = Object.keys(library.playlists).find((playlistId) => {
    let playlist = library.playlists[playlistId]
    return playlist.episodeId === episodeId && playlist.name === track.session
  })

  if (!playlistId) {
    playlistId = ulid()
    library.playlists[playlistId] = {
      episodeId: episodeId,
      name: track.session
    }
  }

  if (!trackId) {
    trackId = ulid()
    library.tracks[trackId] = {}
    if (track.artist) {
      library.tracks[trackId].artist = track.artist.trim().replace(/['"](.+)['"]/, '$1')
    }
    if (track.title) {
      library.tracks[trackId].title = track.title.trim().replace(/['"](.+)['"]/, '$1')
    }
    newTrackCount++
  }

  const hasTrack = find(library.episodes[episodeId].tracks, {
    'trackId': trackId
  })
  if (!hasTrack) {
    let episodeTrack = {
      playlistId: playlistId,
      trackId: trackId,
      startAt: moment.duration().add(index * 180, 's').toJSON(),
      endAt: moment.duration().add((index + 1) * 180, 's').subtract(500, 'millisecond').toJSON()
    }
    episode.tracks.push(episodeTrack)
  }
  episode.tracks = episode.tracks.map((track) => {
    if (track.trackId === trackId) {
      track.playlistId = playlistId
    }

    return track
  })
})

let tracks = sortBy(episode.tracks, (t) => {
  return moment.duration(t.startAt).asMilliseconds()
})

episode.tracks = tracks
library.episodes[episodeId] = episode

jsonfile.writeFileSync('./library.json', library, {spaces: 2})

console.log(`Finished Processing Episode #${program.episode}, added ${newTrackCount} new tracks`)
process.exit()
