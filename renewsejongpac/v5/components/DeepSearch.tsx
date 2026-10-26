"use client";

import Script from "next/script";
import { useEffect, useRef, useState } from "react";
import { searchContent } from "../src/lib/discovery";

type SearchMessage = { role?: string; text?: string };
type ResponseSignal = { onResponse: (reply: { text?: string; error?: string }) => void | Promise<void> };
type DeepSearchElement = HTMLElement & {
    connect?: { handler: (body: { messages?: SearchMessage[] }, signals: ResponseSignal) => void };
    loadHistory?: () => SearchMessage[];
    requestBodyLimits?: { maxMessages: number };
    introMessage?: { text: string };
};

const DEEP_CHAT_CDN = "https://unpkg.com/deep-chat@2.5.1/dist/deepChat.bundle.js";
const MAX_QUERY_LENGTH = 100;
const sanitizeLabel = (value: string) => value.replace(/[\[\]()<>`*_]/g, " ").replace(/\s+/g, " ").trim().slice(0, 70);
const toPath = (path: string) => /^\/[\w/-]+$/i.test(path) ? "/v5" + (path === "/" ? "/" : path.replace(/\/$/, "") + "/") : "/v5/search/";

export function localSearchReply(input: string): string {
    const term = String(input || "").trim().slice(0, MAX_QUERY_LENGTH);
    if (!term) return "공연, 전시, 공간 또는 방문 정보에 관한 검색어를 입력해 주세요.";
    const results = searchContent(term).slice(0, 8);
    const searchUrl = "/v5/search/?q=" + encodeURIComponent(term);
    if (!results.length) return "‘" + sanitizeLabel(term) + "’에 맞는 등록 콘텐츠를 찾지 못했어요.\n\n[일반 검색 페이지에서 다시 찾기](" + searchUrl + ")";
    const links = results.map((item: { title: string; path: string; description?: string }) =>
        "- [" + sanitizeLabel(item.title) + "](" + toPath(item.path) + ")" +
        (item.description ? " — " + sanitizeLabel(item.description).slice(0, 90) : ""));
    return "**‘" + sanitizeLabel(term) + "’ 검색 결과** (" + results.length + "개 우선 표시)\n\n" +
        links.join("\n") + "\n\n[전체 검색 결과 보기](" + searchUrl + ")\n\n" +
        "안내 내용은 등록된 콘텐츠를 기준으로 합니다. 실제 일정·예매 가능 여부는 공식 페이지에서 확인해 주세요.";
}

/**
 * Search powered by the Deep Chat presentation layer and the local discovery index.
 * It never sends a search query to an external LLM/API and needs no provider key.
 * Native GET search stays available if the third-party script fails to load.
 */
export default function DeepSearch({ initialQuery = "", compact = false }: { initialQuery?: string; compact?: boolean }) {
    const mount = useRef<HTMLDivElement>(null);
    const [loaded, setLoaded] = useState(false);
    const [failed, setFailed] = useState(false);
    const firstQuery = useRef(initialQuery.trim().slice(0, MAX_QUERY_LENGTH));

    useEffect(() => {
        const node = mount.current;
        if (!loaded || !node || node.querySelector("deep-chat")) return;
        const chat = document.createElement("deep-chat") as DeepSearchElement;
        chat.style.display = "block";
        chat.style.width = "100%";
        chat.style.height = compact ? "min(390px, 48vh)" : "min(480px, 60vh)";
        chat.style.borderRadius = "14px";
        chat.setAttribute("aria-label", "대화형 콘텐츠 통합 검색");
        chat.introMessage = { text: "무엇을 찾고 계세요? 공연, 전시, 공간, 주차와 방문 안내를 검색해 드릴게요." };
        chat.connect = {
            handler: (body, signals) => {
                const messages = Array.isArray(body.messages) ? body.messages : [];
                const input = [...messages].reverse().find(item => item.role === "user" && typeof item.text === "string")?.text || "";
                void signals.onResponse({ text: localSearchReply(input) });
            },
        };
        chat.requestBodyLimits = { maxMessages: 1 };
        chat.loadHistory = () => firstQuery.current ? [
            { role: "user", text: firstQuery.current },
            { role: "ai", text: localSearchReply(firstQuery.current) },
        ] : [];
        node.appendChild(chat);
        return () => { chat.remove(); };
    }, [loaded, compact]);

    return (
        <div className={"sejong-deep-search" + (compact ? " sejong-deep-search--compact" : "")}>
            <Script
                src={DEEP_CHAT_CDN}
                strategy="afterInteractive"
                onReady={() => setLoaded(true)}
                onError={() => setFailed(true)}
            />
            <div ref={mount} className="sejong-deep-search-mount" aria-label="Deep Chat 대화형 검색" />
            {!loaded && (
                <form className="sejong-deep-search-fallback" action="/v5/search/" method="get" role="search">
                    <label htmlFor={compact ? "deep-search-header" : "deep-search-page"}>검색어</label>
                    <div className="sejong-deep-search-fallback-row">
                        <input id={compact ? "deep-search-header" : "deep-search-page"} type="search" name="q" maxLength={MAX_QUERY_LENGTH} defaultValue={firstQuery.current} placeholder="공연, 전시, 공간 및 방문 정보" required />
                        <button type="submit">검색</button>
                    </div>
                    {failed && <p role="status">대화형 검색을 불러오지 못해 기본 검색으로 전환했어요.</p>}
                </form>
            )}
        </div>
    );
}
