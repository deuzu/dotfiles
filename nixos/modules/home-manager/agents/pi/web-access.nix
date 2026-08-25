{ ... }:
{
  provider = "google";
  searchRouting = {
    providers = [ "exa" ];
    fallbackOn = [ "transient" "quota" "network" "invalid-response" ];
  };
  fetchRouting = {
    providers = [ "http" ];
  };
  webSearch = {
    enabled = true;
  };
  tools = {
    webSearch = {
      enabled = true;
    };
    sourceCheck = {
      enabled = true;
    };
    fetchContent = {
      enabled = true;
    };
    getSearchContent = {
      enabled = true;
    };
  };
  commands = {
    websearch = {
      enabled = true;
    };
    curator = {
      enabled = true;
    };
    search = {
      enabled = true;
    };
    google-account = {
      enabled = false;
    };
  };
  image = {
    enabled = false;
  };
  searchModel = "gemini-3.7-flash";
  summaryModel = "gemini-3.7-flash";
  youtube = {
    enabled = false;
  };
  video = {
    enabled = false;
  };
  pdf = {
    enabled = true;
    maxSizeMB = 20;
    provider = "auto";
  };
}
