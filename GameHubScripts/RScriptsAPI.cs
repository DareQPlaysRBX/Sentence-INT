using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using System.Linq;

namespace SentenceRBX.ScriptHub
{
    public class RscriptsAPI
    {
        private readonly HttpClient _httpClient;
        private const string BASE_URL = "https://rscripts.net/api/v2";
        private const int PER_PAGE = 8;

        public RscriptsAPI()
        {
            _httpClient = new HttpClient
            {
                Timeout = TimeSpan.FromSeconds(30)
            };
        }

        /// <summary>
        /// Pobiera listę skryptów z filtrami
        /// </summary>
        public async Task<RscriptsResponse> GetScriptsAsync(RscriptsFilter filter = null)
        {
            try
            {
                filter ??= new RscriptsFilter();

                var queryParams = new List<string>();

                queryParams.Add($"max={PER_PAGE}");

                if (filter.Page > 0)
                    queryParams.Add($"page={filter.Page}");

                if (filter.NoKeySystem.HasValue)
                    queryParams.Add($"noKeySystem={filter.NoKeySystem.Value.ToString().ToLower()}");

                if (filter.MobileOnly.HasValue)
                    queryParams.Add($"mobileOnly={filter.MobileOnly.Value.ToString().ToLower()}");

                if (filter.NotPaid.HasValue)
                    queryParams.Add($"notPaid={filter.NotPaid.Value.ToString().ToLower()}");

                if (filter.Unpatched.HasValue)
                    queryParams.Add($"unpatched={filter.Unpatched.Value.ToString().ToLower()}");

                if (filter.VerifiedOnly.HasValue)
                    queryParams.Add($"verifiedOnly={filter.VerifiedOnly.Value.ToString().ToLower()}");

                if (!string.IsNullOrEmpty(filter.OrderBy))
                    queryParams.Add($"orderBy={filter.OrderBy}");

                if (!string.IsNullOrEmpty(filter.Sort))
                    queryParams.Add($"sort={filter.Sort}");

                if (!string.IsNullOrEmpty(filter.SearchQuery))
                    queryParams.Add($"q={Uri.EscapeDataString(filter.SearchQuery)}");

                var url = $"{BASE_URL}/scripts";
                if (queryParams.Count > 0)
                    url += "?" + string.Join("&", queryParams);

                var request = new HttpRequestMessage(HttpMethod.Get, url);

                if (!string.IsNullOrEmpty(filter.Username))
                    request.Headers.Add("Username", filter.Username);

                var response = await _httpClient.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<RscriptsResponse>(json);
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to fetch scripts: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Pobiera pojedynczy skrypt po ID
        /// </summary>
        public async Task<ScriptData> GetScriptByIdAsync(string scriptId)
        {
            try
            {
                var url = $"{BASE_URL}/script?id={scriptId}";
                var response = await _httpClient.GetAsync(url);
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();

                var result = JsonConvert.DeserializeObject<SingleScriptResponse>(json);

                return result?.Script;
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to fetch script: {ex.Message}", ex);
            }
        }

        public class SingleScriptResponse
        {
            [JsonProperty("script")]
            public ScriptData Script { get; set; } 
        }

        /// <summary>
        /// Pobiera zawartość skryptu (raw script)
        /// </summary>
        public async Task<string> DownloadScriptContentAsync(string rawScriptUrl)
        {
            try
            {
                var response = await _httpClient.GetAsync(rawScriptUrl);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to download script: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Pobiera skrypt i jego rzeczywistą zawartość
        /// </summary>
        public async Task<ScriptData> GetScriptWithContentAsync(string scriptId)
        {
            try
            {
                // Pobierz metadane skryptu
                var script = await GetScriptByIdAsync(scriptId);

                if (script == null)
                {
                    throw new Exception("Script not found");
                }

                // Jeśli RawScript jest URL, pobierz rzeczywistą zawartość
                if (!string.IsNullOrWhiteSpace(script.RawScript))
                {
                    // Sprawdź czy to URL
                    if (script.RawScript.StartsWith("http://") || script.RawScript.StartsWith("https://"))
                    {
                        System.Diagnostics.Debug.WriteLine($"[RscriptsAPI] RawScript is URL: {script.RawScript}");

                        try
                        {
                            // Pobierz zawartość ze URL
                            var content = await _httpClient.GetStringAsync(script.RawScript);
                            script.RawScript = content;

                            System.Diagnostics.Debug.WriteLine($"[RscriptsAPI] Downloaded script content: {content.Length} bytes");
                        }
                        catch (Exception urlEx)
                        {
                            System.Diagnostics.Debug.WriteLine($"[RscriptsAPI] Failed to download from URL: {urlEx.Message}");
                            throw new Exception($"Failed to download script content from URL: {urlEx.Message}", urlEx);
                        }
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"[RscriptsAPI] RawScript is content (not URL): {script.RawScript.Length} bytes");
                    }
                }
                else
                {
                    throw new Exception("Script has no RawScript data");
                }

                return script;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[RscriptsAPI] GetScriptWithContentAsync error: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Pobiera listę skryptów z filtrami i zwraca jako ViewModels gotowe dla frontendu
        /// </summary>
        public async Task<(List<ScriptViewModel> Scripts, PageInfo Info)> GetScriptsForDisplayAsync(RscriptsFilter filter = null)
        {
            try
            {
                var response = await GetScriptsAsync(filter);

                if (response == null)
                    return (new List<ScriptViewModel>(), new PageInfo { CurrentPage = 1, MaxPages = 1 });

                var viewModels = ScriptViewModel.FromApiDataList(response.Scripts);

                System.Diagnostics.Debug.WriteLine($"[RscriptsAPI] Converted {response.Scripts?.Count ?? 0} scripts to {viewModels.Count} view models");

                return (viewModels, response.Info ?? new PageInfo { CurrentPage = 1, MaxPages = 1 });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[RscriptsAPI] GetScriptsForDisplayAsync error: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// ViewModel dla frontend - mapuje dane z API do formatu oczekiwanego przez JavaScript
        /// </summary>
        public class ScriptViewModel
        {
            [JsonProperty("id")]
            public string Id { get; set; }

            [JsonProperty("title")]
            public string Title { get; set; }

            [JsonProperty("description")]
            public string Description { get; set; }

            [JsonProperty("imageUrl")]
            public string ImageUrl { get; set; }

            [JsonProperty("author")]
            public string Author { get; set; }

            [JsonProperty("gameTitle")]
            public string GameTitle { get; set; }

            [JsonProperty("categoryId")]
            public string CategoryId { get; set; }

            [JsonProperty("category")]
            public string Category { get; set; }

            [JsonProperty("views")]
            public int Views { get; set; }

            [JsonProperty("likes")]
            public int Likes { get; set; }

            [JsonProperty("keySystem")]
            public bool KeySystem { get; set; }

            /// <summary>
            /// Konwertuje ScriptData z API na ScriptViewModel dla frontendu
            /// </summary>
            public static ScriptViewModel FromApiData(ScriptData data)
            {
                if (data == null)
                    return null;

                return new ScriptViewModel
                {
                    Id = data.Id,
                    Title = data.Title ?? "Untitled Script",
                    Description = data.Description ?? "No description available",
                    ImageUrl = data.Image ?? data.Game?.ImageUrl ?? "",
                    Author = data.User?.Username ?? "Unknown",
                    GameTitle = data.Game?.Title ?? "Universal",
                    CategoryId = DetermineCategoryId(data),
                    Category = DetermineCategory(data),
                    Views = data.Views,
                    Likes = data.Likes,
                    KeySystem = data.KeySystem
                };
            }

            /// <summary>
            /// Konwertuje listę ScriptData na listę ScriptViewModel
            /// </summary>
            public static List<ScriptViewModel> FromApiDataList(List<ScriptData> dataList)
            {
                if (dataList == null)
                    return new List<ScriptViewModel>();

                return dataList
                    .Where(d => d != null && !string.IsNullOrEmpty(d.Id))
                    .Select(FromApiData)
                    .Where(vm => vm != null)
                    .ToList();
            }

            /// <summary>
            /// Określa ID kategorii na podstawie danych skryptu
            /// </summary>
            private static string DetermineCategoryId(ScriptData data)
            {
                // Premium - płatne skrypty
                if (data.Paid)
                    return "premium";

                // Universal - skrypty bez przypisanej gry
                if (data.Game == null || string.IsNullOrEmpty(data.Game.Title))
                    return "universal";

                // Hub - skrypty z wieloma grami lub "hub" w tytule
                if (data.Title?.ToLower().Contains("hub") == true)
                    return "hub";

                // Game - zwykłe skrypty do gier
                return "game";
            }

            /// <summary>
            /// Określa nazwę kategorii wyświetlaną w UI
            /// </summary>
            private static string DetermineCategory(ScriptData data)
            {
                if (data.Paid)
                    return "Premium";

                if (data.Game == null || string.IsNullOrEmpty(data.Game.Title))
                    return "Universal";

                if (data.Title?.ToLower().Contains("hub") == true)
                    return "Hub";

                return "Game";
            }
        }
    }

    #region Models

    public class RscriptsFilter
    {
        public int Page { get; set; } = 1;
        public bool? NoKeySystem { get; set; }
        public bool? MobileOnly { get; set; }
        public bool? NotPaid { get; set; }
        public bool? Unpatched { get; set; }
        public bool? VerifiedOnly { get; set; }
        public string OrderBy { get; set; } = "date";
        public string Sort { get; set; } = "desc";
        public string SearchQuery { get; set; }
        public string Username { get; set; }
    }

    public class RscriptsResponse
    {
        [JsonProperty("info")]
        public PageInfo Info { get; set; }

        [JsonProperty("scripts")]
        public List<ScriptData> Scripts { get; set; }
    }

    public class ScriptResponse
    {
        [JsonProperty("script")]
        public List<ScriptData> Script { get; set; }
    }

    public class PageInfo
    {
        [JsonProperty("currentPage")]
        public int CurrentPage { get; set; }

        [JsonProperty("maxPages")]
        public int MaxPages { get; set; }
    }

    public class ScriptData
    {
        [JsonProperty("_id")]
        public string Id { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("views")]
        public int Views { get; set; }

        [JsonProperty("likes")]
        public int Likes { get; set; }

        [JsonProperty("dislikes")]
        public int Dislikes { get; set; }

        [JsonProperty("keySystem")]
        public bool KeySystem { get; set; }

        [JsonProperty("mobileReady")]
        public bool MobileReady { get; set; }

        [JsonProperty("paid")]
        public bool Paid { get; set; }

        [JsonProperty("image")]
        public string Image { get; set; }

        [JsonProperty("rawScript")]
        public string RawScript { get; set; }

        [JsonProperty("createdAt")]
        public DateTime CreatedAt { get; set; }

        [JsonProperty("lastUpdated")]
        public DateTime LastUpdated { get; set; }

        [JsonProperty("user")]
        public UserData User { get; set; }

        [JsonProperty("game")]
        public GameData Game { get; set; }

        [JsonProperty("testedExecutors")]
        public List<ExecutorData> TestedExecutors { get; set; }
    }

    public class UserData
    {
        [JsonProperty("_id")]
        public string Id { get; set; }

        [JsonProperty("username")]
        public string Username { get; set; }

        [JsonProperty("image")]
        public string Image { get; set; }

        [JsonProperty("verified")]
        public bool Verified { get; set; }

        [JsonProperty("admin")]
        public bool Admin { get; set; }
    }

    public class GameData
    {
        [JsonProperty("_id")]
        public string Id { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("placeId")]
        public string PlaceId { get; set; }

        [JsonProperty("imgurl")]
        public string ImageUrl { get; set; }

        [JsonProperty("gameLink")]
        public string GameLink { get; set; }
    }

    public class ExecutorData
    {
        [JsonProperty("_id")]
        public string Id { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("image")]
        public string Image { get; set; }

        [JsonProperty("platforms")]
        public List<string> Platforms { get; set; }
    }

    #endregion
}
