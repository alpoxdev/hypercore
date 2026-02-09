# convertFileSrc()로 로컬 파일 렌더링

## 왜 중요한가

Tauri 앱에서 로컬 파일을 브라우저에서 렌더링하려면 `asset:` 프로토콜 URL로 변환해야 합니다. 직접 파일 경로를 사용하면 CORS 에러가 발생하고, base64 변환은 메모리 낭비와 성능 저하를 일으킵니다.

## ❌ 잘못된 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useState, useEffect } from 'react'

function ImageViewer({ filePath }: { filePath: string }) {
  const [imageData, setImageData] = useState('')

  useEffect(() => {
    // ❌ 파일을 base64로 읽어서 메모리에 전체 로드
    invoke<string>('read_file_as_base64', { path: filePath })
      .then(base64 => setImageData(`data:image/png;base64,${base64}`))
  }, [filePath])

  return <img src={imageData} alt="Local file" />
}
```

**문제점:**
- 파일 전체를 메모리에 로드 (큰 파일 시 느림)
- Rust ↔ JS 직렬화 오버헤드
- 비디오/오디오 스트리밍 불가능

## ✅ 올바른 패턴

```tsx
import { convertFileSrc } from '@tauri-apps/api/core'

function ImageViewer({ filePath }: { filePath: string }) {
  // ✅ 파일 경로를 asset: 프로토콜 URL로 변환
  const assetUrl = convertFileSrc(filePath)

  return <img src={assetUrl} alt="Local file" />
}
```

**비디오/오디오 예시:**

```tsx
import { convertFileSrc } from '@tauri-apps/api/core'

function VideoPlayer({ videoPath }: { videoPath: string }) {
  const videoUrl = convertFileSrc(videoPath)

  return (
    <video controls>
      <source src={videoUrl} type="video/mp4" />
      Your browser does not support video playback.
    </video>
  )
}

function AudioPlayer({ audioPath }: { audioPath: string }) {
  const audioUrl = convertFileSrc(audioPath)

  return (
    <audio controls>
      <source src={audioUrl} type="audio/mpeg" />
    </audio>
  )
}
```

**PDF 뷰어 예시:**

```tsx
import { convertFileSrc } from '@tauri-apps/api/core'

function PDFViewer({ pdfPath }: { pdfPath: string }) {
  const pdfUrl = convertFileSrc(pdfPath)

  return (
    <iframe
      src={pdfUrl}
      width="100%"
      height="600px"
      title="PDF Viewer"
    />
  )
}
```

**동적 파일 목록:**

```tsx
import { convertFileSrc } from '@tauri-apps/api/core'
import { readDir } from '@tauri-apps/plugin-fs'
import { useEffect, useState } from 'react'

function ImageGallery({ dirPath }: { dirPath: string }) {
  const [images, setImages] = useState<string[]>([])

  useEffect(() => {
    readDir(dirPath).then(entries => {
      const imageUrls = entries
        .filter(e => /\.(png|jpg|jpeg|gif)$/i.test(e.name))
        .map(e => convertFileSrc(e.path))
      setImages(imageUrls)
    })
  }, [dirPath])

  return (
    <div className="gallery">
      {images.map((url, i) => (
        <img key={i} src={url} alt={`Image ${i}`} />
      ))}
    </div>
  )
}
```

## 추가 컨텍스트

**asset: 프로토콜 작동 방식:**
- `convertFileSrc('/path/to/file.png')` → `asset://localhost/path/to/file.png`
- Tauri 런타임이 프로토콜 요청을 가로채서 파일 스트림 제공
- 브라우저는 일반 HTTP 리소스처럼 처리 (캐싱, 부분 로드 지원)

**권한 설정 (tauri.conf.json):**

```json
{
  "app": {
    "security": {
      "assetProtocol": {
        "enable": true,
        "scope": [
          "$APPDATA/**",
          "$RESOURCE/**"
        ]
      }
    }
  }
}
```

**파일 경로 타입:**
- 절대 경로: `/Users/name/file.png`, `C:\Users\name\file.png`
- 앱 리소스 경로: `$RESOURCE/assets/image.png`
- AppData 경로: `$APPDATA/cache/thumb.png`

**브라우저 캐싱:**
- asset: URL은 브라우저 캐시 활용 (동일 파일 재요청 방지)
- base64 Data URL은 캐싱 불가

**참고:** [Asset Protocol Scope](https://beta.tauri.app/develop/calling-rust/#asset-protocol-scope)

영향도: HIGH - 성능, 메모리 사용량, 스트리밍 지원
